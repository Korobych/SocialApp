//
//  GeoViewController.swift
//  SocialApp
//
//  Created by Sergey Korobin on 19.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GeoViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            // call for the location data
            locationManager.requestLocation()
        } else {
            print("Switch on Geo services!")
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("Координаты: \(lat),\(long)\n")
            
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            //        mapView.mapType = MKMapType.standard
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: locValue, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locValue
            annotation.title = "You are here!"
            annotation.subtitle = "damn, i found you!"
            mapView.addAnnotation(annotation)
        } else {
            print("No coordinates")
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка геопозиции: \(error.localizedDescription)")
    }
    
    // disable Nav Bar in this view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}
