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
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    // Local profile var added.
    // | //
    // ↓ //
    var currentProfile: Profile!
    var activityIndicatorView: UIView!
    // Location update logic
    var currentLocation: [Double] = []
    var didGetFirstLocation: Bool = false
    // In code volUserModel keeping.
    // | //
    // ↓ //
    var volData: [VolUserModel] = []
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setupMidButton()
        
        profileManager.delegate = self
        mapView.delegate = self
        mapView.mapType = .standard
        NotificationCenter.default.addObserver(self, selector:#selector(locationManagerCustomSetup), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManagerCustomSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // case of getting local saved profile when the view is shown
        self.profileManager.getProfileInfo()
    }
    
    @objc func locationManagerCustomSetup(){
        
        activityIndicatorView = self.showActivityIndicatorView(uiView: self.view)
        
        if CLLocationManager.locationServicesEnabled(){
            didGetFirstLocation = false
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            // accuracy non important setting
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
            mapView.showsScale = true
            mapView.showsCompass = true
            mapView.alpha = 1.0
            mapView.showsUserLocation = false
            
            locationManager.requestLocation()
            
        } else {
            didGetFirstLocation = false
            self.activityIndicatorView.removeFromSuperview()
            SCLAlertView().showError("Невозможно найти геопозицию!", subTitle: "Включите службы геолокации!", closeButtonTitle: "ОК")
            mapView.alpha = 0.4
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            mapView.showsUserLocation = false
            print("\nГеолокация у устройства выключена.\n")
        }
    }
    
    // **************************
    // LocationManager setting up
    // **************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("Координаты: \(lat),\(long)\n")
            // saving current
            self.currentLocation = [lat, long]
            
            if !self.didGetFirstLocation {
                mapView.showsUserLocation = true
                let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
                let span = MKCoordinateSpanMake(0.02, 0.02)
                let region = MKCoordinateRegion(center: locValue, span: span)
                // hide activity indicator here
                self.activityIndicatorView.removeFromSuperview()
                mapView.userTrackingMode = .follow
                mapView.setRegion(region, animated: true)
                locationManager.startUpdatingLocation()
                self.didGetFirstLocation = true
            }

        } else {
            print("No coordinates")
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка геопозиции: \(error.localizedDescription)")
        self.activityIndicatorView.removeFromSuperview()
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
        
        // Logic with exit from account
        DispatchQueue.main.async {
            let exitAlert = UIAlertController(title: "Вы собираетесь выйти из текущего аккаунта!", message: "Уверены, что точно хотите этого?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: "Да", style: .default){ action in
                
                let goodExitAlert = UIAlertController(title: "Вы успешно вышли.", message: "Ждем Вас снова 😎!", preferredStyle: UIAlertControllerStyle.alert)
                self.present(goodExitAlert, animated: true, completion: nil)
                // send POST API request to EXIT
                if self.currentProfile.invId == ""{
                    // vol case
                    APIClient.volExit(phone: self.currentProfile.phone, completion: { (responseObject, error) in
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "true"{
                                print("\nУспешный выход из аккаунта на сервере!\n")
                            } else if status == "false"{
                                print("\nОшибка! Неуспешный выход из аккаунта на сервере!\n")
                            } else {
                                print("some strange status handled!\n\(status)")
                            }
                        } else {
                            if let e = error{
                                print(e.localizedDescription)
                                // handle more errors here TODO!
                                SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                            }
                        }
                    })
                } else {
                    // inv case
                    APIClient.invExit(id: self.currentProfile.invId, completion: { (responseObject, error) in
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "true"{
                                print("\nУспешный выход из аккаунта на сервере!\n")
                            } else if status == "false"{
                                print("\nОшибка! Неуспешный выход из аккаунта на сервере!\n")
                            } else {
                                print("some strange status handled!\n\(status)")
                            }
                        } else {
                            if let e = error{
                                print(e.localizedDescription)
                                // handle more errors here TODO!
                                SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                            }
                        }
                    })
                }
                self.locationManager.stopUpdatingLocation()
                // also delete data from User class and UserDefaults/Core Data!
                self.profileManager.deleteProfile()
                
                let when = DispatchTime.now() + 2.0
                DispatchQueue.main.asyncAfter(deadline: when){
                    goodExitAlert.dismiss(animated: true, completion: {
                    // removing GeoViewController and show previous LoginView
                    print("Выход из аккаунта в UI удачно произошел.\n")
                    self.navigationController?.popViewController(animated: true)
                    })
                }
                
            }
            let denyAction = UIAlertAction(title: "Нет", style: .cancel)
            exitAlert.addAction(confirmAction)
            exitAlert.addAction(denyAction)
            self.present(exitAlert, animated: true, completion: nil)
        
        }
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
        // testing energy consumption
//        mapView.showsUserLocation = false
//        locationManager.stopUpdatingLocation()
        
        if self.currentProfile.invId == ""{
            // vol case
            APIClient.volHelp(phone: self.currentProfile.phone, latitude: self.currentLocation[0].description, longitude: self.currentLocation[1].description) { (responseObject, error) in
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "true"{
                        print("\nТеперь вы готовы помочь! Статус 1.\n")
                    } else if status == "false"{
                        print("\nОшибка! Неуспешная попытка volHelp!\n")
                    } else {
                        print("some strange status handled!\n\(status)")
                    }
                } else {
                    if let e = error{
                        print(e.localizedDescription)
                        // handle more errors here TODO!
                        SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                    }
                }
            }
        } else {
            // inv case
            APIClient.invHelp(id: self.currentProfile.invId, latitude: self.currentLocation[0].description, longitude: self.currentLocation[1].description) { (responseObject, error) in
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "-1"{
                        print("\nОшибка! Неуспешная попытка invHelp!\n")
                    } else {
                        print("\nОтлично! Поиск волонтера сейчас начнется! Ваш conID = \(status).\n")
                        // call for function to show pins of users
                        self.loadVolPins()
                    }
                } else {
                    if let e = error{
                        print(e.localizedDescription)
                        // handle more errors here TODO!
                        SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                    }
                }
            }
        }
        SCLAlertView().showSuccess("Поздравляем!", subTitle: "Скоро случится магия.", closeButtonTitle: "ОК")
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
    
    func loadVolPins(){
        APIClient.volGeoList { (responseObject, error) in
            if error == nil {
                
                let responseArray = responseObject?.value(forKey: "resp") as! NSArray
                for index in (0...responseArray.count - 1){
                    let item = responseArray[index] as! NSArray
                    
                    if item[0] as! String == "" || item[1] as! String == "" || item[3] as! String == "" || item[4] as! String == "" {
                        continue
                    }
                    // Bad things going on here REWRITE
                    guard let lat = item[0] as? String else {return}
                    guard let long = item[1] as? String else {return}
                    guard let status = item[2] as? String else {return}
                    
                    let latDouble = Double(lat)!
                    let longDouble = Double(long)!
                    let statusInt = Int(status)!
                    
                    
                    let volUser = VolUserModel(name: item[3] as! String, phone: item[4] as! String, latitude: latDouble, longitude: longDouble, status: statusInt)
                    self.volData.append(volUser)
                }
                
                print(self.volData)
                // drawing them
                for user in self.volData{
                    let pin = CustomPin(title: user.name, subtitle: user.phone, coordinate: CLLocationCoordinate2DMake(user.latitude, user.longitude))
                    self.mapView.addAnnotation(pin)
                    print("Есть волонтер на карте!")
                }
                
                
                
            } else {
                if let e = error{
                    print(e.localizedDescription)
                    // handle more errors here TODO!
                    SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                }
            }
        }
    }
}

extension GeoViewController: ProfileManagerDelegateProtocol{
    func didFinishSave(success: Bool) {
        // do nothing here
    }
    
    func didFinishDeleting(success: Bool) {
        if success{
            print("\nЛокальный пользователь успешно удален!\n")
        }
    }
    
    func didFinishReading(profile: Profile) {
        self.currentProfile = profile
        print("\nЗагрузка профиля в код! Готово!")
    }
    
}
