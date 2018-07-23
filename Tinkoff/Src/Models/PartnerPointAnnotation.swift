import Foundation
import MapKit

public class PartnerPointAnnotation: NSObject, MKAnnotation {

    public let pointId : String
    
    public let coordinate: CLLocationCoordinate2D
    public let iconName: String
    public let icon: () -> Promise<(name:String, image: UIImage)>

    public init(pointId: String, latitude: Double, longitude: Double, iconName: String, icon: @escaping () -> Promise<(name:String, image: UIImage)>) {
        self.pointId = pointId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.iconName = iconName
        self.icon = icon
    }
    
    override public var hash: Int {
        return pointId.hashValue
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let point = object as? PartnerPointAnnotation else {
            return false
        }
        return point.pointId == self.pointId
    }
    
    override public var description: String { return pointId }

}
