//
//  MapViewController.swift
//  uikitgeoposition
//
//  Created by Anton Petrenko on 19/07/2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MKMapView()
        view = mapView
        let location: CLLocationCoordinate2D = .init(latitude: 52.193, longitude: 20.938)
        mapView.region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "Żabkes"
        pin.subtitle = "Best Żabkes ever"
        mapView.addAnnotation(pin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.start()
    }
}

