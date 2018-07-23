import Foundation
import CoreData
import MapKit.MKGeometry

public extension MapRect {

    func fill(by mapRect: MKMapRect) -> MapRect {
        self.originX = mapRect.origin.x
        self.originY = mapRect.origin.y
        self.width = mapRect.size.width
        self.height = mapRect.size.height
        return self
    }

    func convert() -> MKMapRect {
        return MKMapRect(origin: MKMapPoint(x: self.originX, y: self.originY), size: MKMapSize(width: self.width, height: self.height))
    }

    static func getAll(in context: NSManagedObjectContext) -> [MapRect]? {
        do {
            let fetchRequest: NSFetchRequest<MapRect> = MapRect.fetchRequest()
            return try context.fetch(fetchRequest)
        } catch {
            log(error)
            return nil
        }
    }

    static func deleteAll(in context: NSManagedObjectContext) {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MapRect.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        } catch {
            log(error)
        }
    }

}
