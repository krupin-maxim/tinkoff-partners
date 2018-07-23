import Foundation
import CoreData


extension PartnerPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PartnerPoint> {
        return NSFetchRequest<PartnerPoint>(entityName: "PartnerPoint")
    }

    @NSManaged public var externalId: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var partnerName: String?
    @NSManaged public var workHours: String?
    @NSManaged public var toPartner: Partner?

}
