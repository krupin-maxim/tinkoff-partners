import Foundation
import MapKit.MKGeometry

public protocol PointsProvider {

    func getPointAnnotations(mapRect: MKMapRect) -> Promise<[PartnerPointAnnotation]>

}
