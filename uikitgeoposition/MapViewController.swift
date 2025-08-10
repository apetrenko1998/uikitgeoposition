//
//  MapViewController.swift
//  uikitgeoposition
//
//  Created by Anton Petrenko on 19/07/2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let manager = CLLocationManager()
    private var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MKMapView()
        view = mapView
        mapView.showsUserLocation = true
        let location: CLLocationCoordinate2D = .init(latitude: 52.193, longitude: 20.938)
        mapView.region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "Żabkes"
        pin.subtitle = "Best Żabkes ever"
        mapView.addAnnotation(pin)
        self.mapView = mapView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        @unknown default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let mapView = mapView, let lastLocation = locations.last else { return }
//        mapView.annotations.forEach { mapView.removeAnnotation($0) }
//        let pin = MKPointAnnotation()
//        pin.coordinate = lastLocation.coordinate
//        pin.title = "New loc"
//        pin.subtitle = "Some new loc"
//        mapView.addAnnotation(pin)
        print("Locations: \(locations)")
//        mapView.region = MKCoordinateRegion(center: lastLocation.coordinate,
//                                            latitudinalMeters: 1000,
//                                            longitudinalMeters: 1000)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error" + String(describing: error))
    }
}
