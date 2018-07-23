import Foundation
import MapKit.MKGeometry

public extension MKMapRect {

    func convertToCircle() -> (center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let center = MKCoordinateRegionForMapRect(self).center
        let northEastPoint = MKMapPoint(x: MKMapRectGetMinX(self), y: MKMapRectGetMinY(self))
        let southWestPoint = MKMapPoint(x: MKMapRectGetMaxX(self), y: MKMapRectGetMaxY(self))
        let radius = MKMetersBetweenMapPoints(northEastPoint, southWestPoint) / 2
        return (center: center, radius: radius)
    }

}

public extension MKCoordinateRegion {

    func getTopLeft() -> CLLocationCoordinate2D {
        var topLeft = CLLocationCoordinate2D(
            latitude: min(self.center.latitude + (self.span.latitudeDelta/2.0), 90),
            longitude: self.center.longitude - (self.span.longitudeDelta/2.0)
        )

        if topLeft.longitude < -180 {
            // We wrapped around the meridian
            topLeft.longitude += 360
        }
        return topLeft
    }

    func getBottomRight() -> CLLocationCoordinate2D {
        var bottomRight = CLLocationCoordinate2D(
            latitude: max(self.center.latitude - (self.span.latitudeDelta/2.0), -90),
            longitude: self.center.longitude + (self.span.longitudeDelta/2.0)
        )

        if bottomRight.longitude > 180 {
            // We wrapped around the medridian
            bottomRight.longitude -= 360
        }
        return bottomRight
    }

    func convertToMapRect() -> MKMapRect {
        let topLeftMapPoint = MKMapPointForCoordinate(getTopLeft())
        let bottomRightMapPoint = MKMapPointForCoordinate(getBottomRight())

        var width = bottomRightMapPoint.x - topLeftMapPoint.x
        if width < 0.0 {
            // Rect crosses meridian
            width += MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: 0.0, longitude: 180.0)).x
        }
        let height = bottomRightMapPoint.y - topLeftMapPoint.y
        let size = MKMapSize(width: width, height: height)

        return MKMapRect(origin: topLeftMapPoint, size: size)
    }

}