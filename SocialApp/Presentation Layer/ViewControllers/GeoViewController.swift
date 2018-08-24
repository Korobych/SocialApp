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
    var activityIndicatorView: UIView!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setupMidButton()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            // call for the location data
            locationManager.requestLocation()
//            locationManager.startUpdatingLocation()
            activityIndicatorView = self.showActivityIndicatorView(uiView: self.view)
        } else {
            SCLAlertView().showError("Невозможно найти геопозицию!", subTitle: "Включите службы геолокации!", closeButtonTitle: "ОК")
            print("Switch ON Geo services, can't get geolocation.")
        }
    }
    
    // **************************
    // LocationManager setting up
    // **************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("Координаты: \(lat),\(long)\n")
            
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegion(center: locValue, span: span)
            // hide activity indicator here
            self.activityIndicatorView.removeFromSuperview()
        
            mapView.setRegion(region, animated: true)
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
    
    // **************************
    // TabBar setting up
    // **************************
    
    func setupMidButton() {
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        menuButton.backgroundColor = UIColor.white
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.lightGray.cgColor
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        menuButton.setImage(#imageLiteral(resourceName: "handshake_pic"), for: UIControlState.normal)
        menuButton.contentMode = .scaleAspectFit
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        menuButton.addTarget(self, action: #selector(GeoViewController.midButtonAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.layoutIfNeeded()
    }
    
    @objc func midButtonAction(){
        SCLAlertView().showSuccess("Ура!", subTitle: "Вы нажали на кнопку помощи, теперь вы в деле!", closeButtonTitle: "ОК")
    }
    
    func showActivityIndicatorView(uiView: UIView) -> UIView {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.init(red: 0.266, green: 0.266, blue: 0.266, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        
        activityIndicator.startAnimating()
        return container
    }
    
    
}
