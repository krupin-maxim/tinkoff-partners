import FrameworkForPlayground
import PlaygroundSupport
import MapKit

PlaygroundPage.current.needsIndefiniteExecution = true

// You can run it if move CoreDataPointsProvider to FrameworkForPlayground target (thanks to objective c runtime in coredata)

//let pointsProvider = CoreDataPointsProvider()
//
//let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633), 1000, 1000)
//
//pointsProvider.getPointAnnotations(mapRect: region.convertToMapRect())
//    .done { result in
//        log(result)
//    }.catchError { error in
//        log(error)
//    }
