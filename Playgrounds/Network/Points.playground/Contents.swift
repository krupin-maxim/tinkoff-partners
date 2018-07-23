import UIKit
import FrameworkForPlayground
import PlaygroundSupport
import MapKit.MKGeometry

PlaygroundPage.current.needsIndefiniteExecution = true

// https://api.tinkoff.ru/v1/deposition_points?latitude=55.755786&longitude=37.617633&partners=EUROSET&radius=1000

let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633), 1000, 1000)

let searchCircle = region.convertToMapRect().convertToCircle()

let networkManager = HTTPApiManager()

firstly {
    try networkManager.api(.depositionPoints(center: searchCircle.center, radius: searchCircle.radius, partners: ["EUROSET"]), DepositionPointsResponse.self)
}
    .done { payload in
        log(payload)
    }
    .catchError {
        log($0)
    }
