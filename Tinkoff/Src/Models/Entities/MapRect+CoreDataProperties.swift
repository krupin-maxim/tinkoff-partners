import Foundation
import CoreData


extension MapRect {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapRect> {
        return NSFetchRequest<MapRect>(entityName: "MapRect")
    }

    @NSManaged public var originX: Double
    @NSManaged public var originY: Double
    @NSManaged public var width: Double
    @NSManaged public var height: Double

}
