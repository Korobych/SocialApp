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
import SCLAlertView

class GeoViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var decisionButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            // call for the location data
            locationManager.requestLocation()
        } else {
            SCLAlertView().showError("Невозможно найти геопозицию!", subTitle: "Включите службы геолокации!", closeButtonTitle: "ОК")
            print("Switch ON Geo services, can't get geolocation.")
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }
    
    @IBAction func decisionButtonTapped(_ sender: UIButton) {
        
    }
    
    // ********************
    // LocationManager setting up
    // ********************
    
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
    
}

extension GeoViewController{
    
    func setUpNavigationBar(){
        self.navigationItem.title = "Social App"
        self.navigationItem.setHidesBackButton(true, animated: false)
        // setting right NavBar button (exit)
        let exitButton = UIButton(type: .custom)
        exitButton.setImage(#imageLiteral(resourceName: "logOut_pic"), for: .normal)
        exitButton.addTarget(self, action: #selector(GeoViewController.logOut), for: .touchUpInside)
        exitButton.contentMode = .scaleAspectFit
        let rightBarItem = UIBarButtonItem(customView: exitButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func logOut() {
        // Logic with exit from account, no api needed
        DispatchQueue.main.async {
            let exitAlert = UIAlertController(title: "Вы собираетесь выйти из текущего аккаунта!", message: "Уверены, что точно хотите этого?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: "Да", style: .default){ action in
                
                let goodExitAlert = UIAlertController(title: "Вы успешно вышли.", message: "Ждем Вас снова 😎!", preferredStyle: UIAlertControllerStyle.alert)
                self.present(goodExitAlert, animated: true, completion: nil)
                
                let when = DispatchTime.now() + 2.0
                DispatchQueue.main.asyncAfter(deadline: when){
                    goodExitAlert.dismiss(animated: true, completion: {
                    // removing GeoViewController and show previous LoginView
                    print("Выход из аккаунта удачно произошел.\n")
                    self.navigationController?.popViewController(animated: true)
                    })
                }
                
            }
            let denyAction = UIAlertAction(title: "Нет", style: .cancel)
            exitAlert.addAction(confirmAction)
            exitAlert.addAction(denyAction)
            self.present(exitAlert, animated: true, completion: nil)
        
        }
        // also delete data from User class and UserDefaults/Core Data here!
    }
    
    func setUpButtons(){
        
    }
}