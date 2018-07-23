import Foundation
import CoreData
import MapKit.MKGeometry

public class CoreDataPointsProvider: PointsProvider {

    typealias PartnerManagedID = NSManagedObjectID

    fileprivate let accountType = Api.AccountType.credit

    fileprivate lazy var partners: Promise<[String: PartnerManagedID]> = loadIfNeedPartnersAsDictionary()
    fileprivate let coreDataStack = CoreDataStack()
    fileprivate let networkManager: ApiManager
    fileprivate let iconsCache: IconsCache

    public init(networkManager: ApiManager, iconsCache: IconsCache) {
        self.networkManager = networkManager
        self.iconsCache = iconsCache
    }

    public func getPointAnnotations(mapRect: MKMapRect) -> Promise<[PartnerPointAnnotation]> {
        return getPartnerPoints(mapRect: mapRect)
            .map { (partnerPoints: [PartnerPoint]) -> [PartnerPointAnnotation] in
                partnerPoints.compactMap({
                    if let externalId = $0.externalId, let latitude = $0.latitude, let longitude = $0.longitude, let iconName = $0.toPartner?.picture {
                        return PartnerPointAnnotation(pointId: externalId, latitude: Double(truncating: latitude), longitude: Double(truncating: longitude), iconName: iconName,
                            icon: ({ firstly(execute: { [unowned self] () in try self.iconsCache.getImageWithName(iconName) }) }))
                    }
                    return nil
                })
            }
    }

    // MARK: -- Partners

    fileprivate func loadIfNeedPartners() -> Promise<[Partner]> {
        // if last request
        let coreDataPartners = checkAndGetCoreDataPartners()

        if coreDataPartners.count > 0 {
            return Promise { resolver in
                resolver.fulfill(coreDataPartners)
            }
        } else {
            return loadPartners()
        }
    }

    fileprivate func checkAndGetCoreDataPartners() -> [Partner] {
        if UserDefaults.standard.needUpdatePartners() {
            Partner.deleteAll(in: coreDataStack.writeContext)
            MapRect.deleteAll(in: coreDataStack.writeContext)
            coreDataStack.save()
            return []
        } else {
            return getCoreDataPartners()
        }
    }

    fileprivate func getCoreDataPartners() -> [Partner] {
        return Partner.getAll(accountType: accountType.rawValue, in: coreDataStack.readContext) ?? []
    }

    fileprivate func loadPartners() -> Promise<[Partner]> {
        return firstly {
            try networkManager.api(.depositionPartners(accountType: accountType), DepositionPartnersResponse.self)
        }.map { [unowned self] (payload: [DepositionPartnersItem]) in
            let createdPartners: [Partner] = payload.map {
                return Partner(context: self.coreDataStack.writeContext)
                    .fill(by: $0, accountType: self.accountType.rawValue)
            }
            self.coreDataStack.save()
            return createdPartners
        }
    }

    fileprivate func loadIfNeedPartnersAsDictionary() -> Promise<[String: PartnerManagedID]> {
        return loadIfNeedPartners()
            .map { (partners: [Partner]) in
                partners.filter({ $0.hasLocations })
            }
            .map { (partners: [Partner]) in
                var result: [String: PartnerManagedID] = [:]
                partners.forEach { (partner: Partner) in
                    if let partnerId = partner.id {
                        result[partnerId] = partner.objectID
                    }
                }
                return result
            }

    }

    // MARK: -- Points

    fileprivate func getPartnerPoints(mapRect: MKMapRect) -> Promise<[PartnerPoint]> {
        return partners
            .then { [unowned self] (partners: [String: PartnerManagedID]) -> Promise<[PartnerPoint]> in
            if self.checkLoadedRect(mapRect) {
                return self.coreDataPoints(partners: partners, mapRect: mapRect)
            } else {
                return self.loadPoints(partners: partners, mapRect: mapRect)
            }
        }
    }

    func loadPoints(partners: [String: PartnerManagedID], mapRect: MKMapRect) -> Promise<[PartnerPoint]> {
        let partnerIds = Array(partners.keys)
        let circleSearch = mapRect.convertToCircle()
        return firstly {
            try networkManager.api(.depositionPoints(center: circleSearch.center, radius: circleSearch.radius, partners: partnerIds),
                    DepositionPointsResponse.self)
                .map { [unowned self] (payload: [DepositionPointsItem]) -> [PartnerPoint] in
                    let loadedIds = payload.map{ $0.externalId}
                    PartnerPoint.deleteBy(ids: loadedIds, in: self.coreDataStack.writeContext)

                    let createdPoints: [PartnerPoint] = payload.compactMap { (item: DepositionPointsItem) -> PartnerPoint? in
                        let point = PartnerPoint(context: self.coreDataStack.writeContext)
                            .fill(by: item)
                        if let partnerName = point.partnerName, let partner = partners[partnerName],
                           let sameContextPartner = self.coreDataStack.writeContext.object(with: partner) as? Partner {
                            point.toPartner = sameContextPartner
                            return point
                        }
                        return nil
                    }
                    self.replaceLoadedRect(mapRect)
                    self.coreDataStack.save()
                    UserDefaults.standard.updatePartners()
                    return createdPoints
                }
        }
    }

    func coreDataPoints(partners: [String: PartnerManagedID], mapRect: MKMapRect) -> Promise<[PartnerPoint]> {
        let partnerIds = Array(partners.keys)
        return Promise { resolver in
            let points = PartnerPoint.getInRect(mapRect, partnerNames: partnerIds, in: coreDataStack.readContext)
            resolver.fulfill(points ?? [])
        }
    }

    // MARK: -- Rects

    func checkLoadedRect(_ rect: MKMapRect) -> Bool {
        guard let loadedRects = MapRect.getAll(in: coreDataStack.readContext)?
            .map({ $0.convert() }) else {
            return false
        }
        for loadedRect in loadedRects {
            if MKMapRectContainsRect(loadedRect, rect) {
                return true
            }
        }
        return false
    }

    func replaceLoadedRect(_ rect: MKMapRect) {
        let loadedRects = MapRect.getAll(in: coreDataStack.writeContext) ?? []
        for loadedRect in loadedRects {
            if MKMapRectContainsRect(rect, loadedRect.convert()) {
                coreDataStack.writeContext.delete(loadedRect)
            }
        }

        let _ = MapRect(context: coreDataStack.writeContext).fill(by: rect)
    }

}


fileprivate class CoreDataStack {

    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataStack.self)
        guard let modelURL = bundle.url(forResource: Consts.PERSISTANT_CONTAINER_NAME,
            withExtension: "momd") else {
            fatalError("Error getting model url")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        return managedObjectModel
    }()

    fileprivate lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Consts.PERSISTANT_CONTAINER_NAME, managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    fileprivate lazy var masterContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    fileprivate lazy var readContext: NSManagedObjectContext = {
        let result = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        result.parent = masterContext
        return result
    }()

    fileprivate lazy var writeContext: NSManagedObjectContext = {
        let result = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        result.parent = masterContext
        result.mergePolicy = NSOverwriteMergePolicy
        return result
    }()

    fileprivate func save() {
        save(context: writeContext)
        masterContext.performAndWait {
            save(context: masterContext)
        }
    }

    fileprivate func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                log(error)
            }
        }
    }

}
