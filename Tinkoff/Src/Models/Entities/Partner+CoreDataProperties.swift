import Foundation
import CoreData


extension Partner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Partner> {
        return NSFetchRequest<Partner>(entityName: "Partner")
    }

    @NSManaged public var accountType: String?
    @NSManaged public var depositionDuration: String?
    @NSManaged public var descr: String?
    @NSManaged public var externalPartnerId: String?
    @NSManaged public var hasLocations: Bool
    @NSManaged public var id: String?
    @NSManaged public var isMomentary: Bool
    @NSManaged public var limitations: String?
    @NSManaged public var name: String?
    @NSManaged public var picture: String?
    @NSManaged public var pointType: String?
    @NSManaged public var url: String?
    @NSManaged public var toPoints: NSSet?

}

// MARK: Generated accessors for toPoints
extension Partner {

    @objc(addToPointsObject:)
    @NSManaged public func addToToPoints(_ value: PartnerPoint)

    @objc(removeToPointsObject:)
    @NSManaged public func removeFromToPoints(_ value: PartnerPoint)

    @objc(addToPoints:)
    @NSManaged public func addToToPoints(_ values: NSSet)

    @objc(removeToPoints:)
    @NSManaged public func removeFromToPoints(_ values: NSSet)

}
