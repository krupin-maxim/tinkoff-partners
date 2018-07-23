import UIKit
import MapKit

public class MainScreenController: UIViewController {

    public var pointsProvider: PointsProvider?

    fileprivate lazy var map: MKMapView = {
        return MKMapView()
    }()

    fileprivate lazy var locationButton: UIButton = {
        return createButton(imageName: "map_location", #selector(onLocationTap))
    }()

    fileprivate lazy var zoomInButton: UIButton = {
        return createButton(imageName: "map_zoom_in", #selector(onZoomInTap))
    }()

    fileprivate lazy var zoomOutButton: UIButton = {
        return createButton(imageName: "map_zoom_out", #selector(onZoomOutTap))
    }()

    fileprivate lazy var locationManager: CLLocationManager = CLLocationManager()
    
    deinit {
        locationButton.removeTarget(self, action: nil, for: .allEvents)
        zoomInButton.removeTarget(self, action: nil, for: .allEvents)
        zoomOutButton.removeTarget(self, action: nil, for: .allEvents)
    }
}

// All about UIViewController

public extension MainScreenController {

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            map.showsUserLocation = true
            map.setUserTrackingMode(.follow, animated: false)
        } else {
            let location = CLLocation(latitude: 55.755786, longitude: 37.617633) // Default city
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
            map.setRegion(region, animated: true)
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// All about UI
fileprivate extension MainScreenController {

    func setupUI() {
        // -- Add map
        self.view.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            map.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            map.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])

        map.delegate = self
        map.showsScale = true

        // Add buttons

        let stackButtons = UIStackView(arrangedSubviews: [self.zoomOutButton, self.zoomInButton, self.locationButton])
        stackButtons.distribution = .fillEqually
        stackButtons.alignment = .fill
        stackButtons.axis = .horizontal
        stackButtons.spacing = 10

        self.view.addSubview(stackButtons)
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackButtons.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor, constant: 0),
            stackButtons.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -8)
        ])
    }

    func createButton(imageName: String, _ selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let bundle = Bundle(for: MainScreenController.self)
        button.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    @objc func onLocationTap() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            map.showsUserLocation = true
            map.setUserTrackingMode(.follow, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.showLocationAlert()
        }
    }

    @objc func onZoomInTap() {
        var region = map.region
        region.span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2)
        map.setRegion(region, animated: true)
    }

    @objc func onZoomOutTap() {
        var region = map.region
        region.span = MKCoordinateSpan(latitudeDelta: min(region.span.latitudeDelta * 2, 180), longitudeDelta: min(region.span.longitudeDelta * 2, 360))
        map.setRegion(region, animated: true)
    }

}

extension MainScreenController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PartnerPointAnnotation else {
            return nil
        }
        let identifier = "marker"
        let view: AnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = AnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        return view
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (map.visibleMapRect.convertToCircle().radius < 100_000) {
            map.userTrackingMode = .none
            requestPointsFor(mapView.visibleMapRect)
        }
    }

}

extension MainScreenController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            checkLocationAuthorizationStatus()
        case _: break
        }
    }

}

extension MainScreenController {

    func requestPointsFor(_ mapRect: MKMapRect) {
        pointsProvider?.getPointAnnotations(mapRect: mapRect)
            .done{ [weak self] (annotations: [PartnerPointAnnotation]) in
                self?.showAnnotationsFor(mapRect, annotations: annotations)
            }
            .catchError { [weak self] error in
                self?.showRequestError(error)
            }
    }

    func showAnnotationsFor(_ rect: MKMapRect, annotations: [PartnerPointAnnotation]) {
        // TODO: need time to think what to do with big numbers of annotations
        let mapAnnotations = (map.annotations as? [PartnerPointAnnotation]) ?? []
        let (toAdd, toRemove) = mapAnnotations.calcDifferWith(annotations)
        map.addAnnotations(toAdd)
        map.removeAnnotations(toRemove)
    }

    func showRequestError(_ error: Error) {
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        let openAction = UIAlertAction(title: "Повторить", style: .destructive) { [unowned self] (action) in
            self.requestPointsFor(self.map.visibleMapRect)
        }
        self.showAlert(title: "Ошибка в запросе",
            message: "\(error)",
            actions: [cancelAction, openAction])
    }


}

fileprivate class AnnotationView: MKAnnotationView {

    var imageName: String?

    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? PartnerPointAnnotation else {
                return
            }

            canShowCallout = false
            calloutOffset = CGPoint(x: -5, y: 5)

            imageName = annotation.iconName
            annotation.icon().done { [weak self] (name, image) in
                if self?.imageName == name {
                    self?.image = image
                }
            }.catchError { error in
                log(error)
            }

        }
    }

}
