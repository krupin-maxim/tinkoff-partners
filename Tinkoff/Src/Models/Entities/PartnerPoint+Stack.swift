import Foundation
import CoreData
import MapKit.MKGeometry

public extension PartnerPoint {

    public func fill(by response: DepositionPointsItem) -> PartnerPoint {
        self.externalId = response.externalId
        self.fullAddress = response.fullAddress
        self.latitude = NSDecimalNumber(value: response.location.latitude)
        self.longitude = NSDecimalNumber(value: response.location.longitude)
        self.partnerName = response.partnerName
        self.workHours = response.workHours
        return self
    }

    public static func getAll(in context: NSManagedObjectContext) -> [PartnerPoint]? {
        do {
            let request: NSFetchRequest<PartnerPoint> = PartnerPoint.fetchRequest()
            request.returnsObjectsAsFaults = false
            return try context.fetch(request)
        } catch {
            log(error)
            return nil
        }
    }

    public static func getInRect(_ rect: MKMapRect, partnerNames: [String], in context: NSManagedObjectContext) -> [PartnerPoint]? {
        do {
            let request: NSFetchRequest<PartnerPoint> = PartnerPoint.fetchRequest()

            let region = MKCoordinateRegionForMapRect(rect)
            let topLeft = region.getTopLeft()
            let bottomRight = region.getBottomRight()

            request.predicate = NSPredicate(format: "(latitude > %@) AND (latitude < %@) AND (longitude < %@) AND (longitude > %@) AND (partnerName IN %@)",
                NSDecimalNumber(value: bottomRight.latitude),
                NSDecimalNumber(value: topLeft.latitude),
                NSDecimalNumber(value: bottomRight.longitude),
                NSDecimalNumber(value: topLeft.longitude),
                NSArray(array: partnerNames))

            return try context.fetch(request)
        } catch {
            log(error)
            return nil
        }
    }

    public static func deleteBy(ids: [String], in context: NSManagedObjectContext) {
        do {
            let request: NSFetchRequest<NSFetchRequestResult> = PartnerPoint.fetchRequest()
            request.predicate = NSPredicate(format: "(externalId IN %@)",
                NSArray(array: ids))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
        } catch {
            log(error)
        }
    }

}