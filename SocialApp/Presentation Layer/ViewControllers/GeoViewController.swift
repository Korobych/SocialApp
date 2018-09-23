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
    // Timers
    // | //
    // ↓ //
    var volDataUpdateTimer: Timer?
    var localUserGeoUpdateTimer: Timer?
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setupMidButton()
        setupReloadButton()
        
        profileManager.delegate = self
        mapView.delegate = self
        mapView.mapType = .standard
        NotificationCenter.default.addObserver(self, selector:#selector(locationManagerCustomSetup), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        self.locationManager.delegate = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        print("\nGeoView \(#function).")
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
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        self.volDataUpdateTimer?.fire()
        // one more time set the region
        let locValue:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.currentLocation[0], longitude: self.currentLocation[1])
        // set comfort values (the previous was 0.02, 0.02).
        let span = MKCoordinateSpanMake(0.04, 0.04)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
    }

    @objc func locationManagerCustomSetup(){
        
//        activityIndicatorView = self.showActivityIndicatorView(uiView: self.view)
        
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
            mapView.showsUserLocation = true
            
            locationManager.startUpdatingLocation()
            
        } else {
            didGetFirstLocation = false
            SCLAlertView().showError("Невозможно найти геопозицию!", subTitle: "Включите службы геолокации!", closeButtonTitle: "ОК")
            mapView.alpha = 0.4
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            mapView.showsUserLocation = false
            print("\nГеолокация у устройства выключена.\n")
            // timer handling
            // TODO fix CH/ND touch with state = 1
            if self.localUserGeoUpdateTimer != nil{
                self.localUserGeoUpdateTimer?.invalidate()
            }
        }
    }
    
    // **************************
    // LocationManager setting up
    // **************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("Координаты: \(lat),\(long)\n")
            // saving current geo(lat, long) to code
            self.currentLocation = [lat, long]
            
            if !self.didGetFirstLocation {
                mapView.showsUserLocation = true
                // set comfort values (the previous was 0.02, 0.02).
                let span = MKCoordinateSpanMake(0.04, 0.04)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
                mapView.userTrackingMode = .follow
                mapView.setRegion(region, animated: true)
                self.didGetFirstLocation = true
            }

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
                // FIXIT ***********
//                self.profileManager.deleteProfile()
                
                let when = DispatchTime.now() + 2.0
                DispatchQueue.main.asyncAfter(deadline: when){
                    goodExitAlert.dismiss(animated: true, completion: {
                        // removing GeoViewController and show previous LoginView
                        print("Выход из аккаунта в UI удачно произошел.\n")
                        // stop timers
                        if self.volDataUpdateTimer != nil {
                            self.volDataUpdateTimer?.invalidate()
                        }
                        if self.localUserGeoUpdateTimer != nil{
                            self.localUserGeoUpdateTimer?.invalidate()
                        }
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
    
    func setupReloadButton(){
        self.reloadButton.clipsToBounds = true
        self.reloadButton.layer.cornerRadius = self.reloadButton.frame.height/2
        self.reloadButton.setImage(#imageLiteral(resourceName: "reload_pic"), for: .normal)
        self.reloadButton.contentMode = .scaleAspectFit
        self.reloadButton.tintColor = UIColor.gray
        self.reloadButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.reloadButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        self.reloadButton.alpha = 0.0
        self.reloadButton.isEnabled = false
    }
    
    @objc func midButtonAction(){
        if self.currentProfile.invId == ""{
            // vol case
            APIClient.volHelp(phone: self.currentProfile.phone, latitude: self.currentLocation[0].description, longitude: self.currentLocation[1].description) { (responseObject, error) in
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "true"{
                        print("\nТеперь вы готовы помочь! Статус 1.\n")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        //timer to update vol geo by 10 seconds
                        if self.localUserGeoUpdateTimer == nil{
                            self.localUserGeoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                                APIClient.updateVolGeo(phone: self.currentProfile.phone, latitude: self.currentLocation[0].description, longitude: self.currentLocation[1].description, completion: { (responseObject, error) in
                                    if error == nil {
                                        let status = responseObject?.value(forKey: "resp") as! String
                                        if status == "false"{
                                            print("\nОшибка! Неуспешная попытка обновить геопозицию! vol\n")
                                        } else if status == "true" {
                                            print("\nГеопозиция в бд обновлена! vol\n")
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
                        }

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
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)

                        // timer to update set up!  --- selected time is 150 secs
                        DispatchQueue.main.async {
                            self.volDataUpdateTimer = Timer.scheduledTimer(withTimeInterval: 150, repeats: true) { _ in
                                // clear map from previous annotations
                                // TODO: make smarter delete fucntion. If the geo diff is less than const, don't delete it.
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                self.loadVolPins()
                                print("\nТаймер на обновление volGeolist сработал!\n")
                            }
                            //timer to update inv geo by 10 seconds
                            self.localUserGeoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                                APIClient.updateInvGeo(id: self.currentProfile.invId, latitude: self.currentLocation[0].description, longitude: self.currentLocation[1].description, completion: { (responseObject, error) in
                                    if error == nil {
                                        let status = responseObject?.value(forKey: "resp") as! String
                                        if status == "false"{
                                            print("\nОшибка! Неуспешная попытка обновить геопозицию! inv\n")
                                        } else if status == "true" {
                                            print("\nГеопозиция в бд обновлена! inv\n")
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
                            // show reloadButton with animation!
                            self.reloadButton.isEnabled = true
                            UIView.animate(withDuration: 1.5, animations: {
                                self.reloadButton.alpha = 1.0
                            })
                            print("\nКнопка обновления отрисована!\n")
                        }
                        
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
        // REMOVE -- done only for testing!
//        SCLAlertView().showSuccess("Поздравляем!", subTitle: "Скоро случится магия.", closeButtonTitle: "ОК")
    }
    
//    func showActivityIndicatorView(uiView: UIView) -> UIView {
//        let container: UIView = UIView()
//        container.frame = uiView.frame
//        container.center = uiView.center
//        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//
//        let loadingView: UIView = UIView()
//        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//        loadingView.center = uiView.center
//        loadingView.backgroundColor = UIColor.init(red: 0.266, green: 0.266, blue: 0.266, alpha: 0.7)
//        loadingView.clipsToBounds = true
//        loadingView.layer.cornerRadius = 10
//
//        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        activityIndicator.activityIndicatorViewStyle =
//            UIActivityIndicatorViewStyle.whiteLarge
//        activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
//
//        loadingView.addSubview(activityIndicator)
//        container.addSubview(loadingView)
//        uiView.addSubview(container)
//
//        activityIndicator.startAnimating()
//        return container
//    }
    
    @objc func loadVolPins(){
        // clear volUserModel array before getting new values
        self.volData = []
        APIClient.volGeoList { (responseObject, error) in
            if error == nil {
                
                let responseArray = responseObject?.value(forKey: "resp") as! NSArray
                for index in (0...responseArray.count - 1){
                    let item = responseArray[index] as! NSArray
                    
                    if item[0] as! String == "" || item[1] as! String == "" || item[3] as! String == "" || item[4] as! String == "" {
                        continue
                    }
                    // Bad things going on here REWRITE
                    // -------------------------------
                    guard let lat = item[0] as? String else {return}
                    guard let long = item[1] as? String else {return}
                    guard let status = item[2] as? String else {return}
                    
                    let latDouble = Double(lat)!
                    let longDouble = Double(long)!
                    let statusInt = Int(status)!
                    // -------------------------------
                    
                    let volUser = VolUserModel(name: item[3] as! String, phone: item[4] as! String, latitude: latDouble, longitude: longDouble, status: statusInt)
                    self.volData.append(volUser)
                    self.drawVolPins()
                }
                
                print(self.volData)
                
            } else {
                if let e = error{
                    // handle more errors here TODO!
                    print("Не удалось получить данные волонтеров. Ошибка: \(e.localizedDescription).")
                    
                }
            }
        }
    }
    
    func drawVolPins(){
        // drawing pins of preloaded vol/geolist
        // -----
        // TODO: select only state == 1 volonteers -> green color
        // TODO: 
        // -----
        for user in self.volData{
            let pin = CustomPin(title: user.name, subtitle: user.phone, coordinate: CLLocationCoordinate2DMake(user.latitude, user.longitude))
            self.mapView.addAnnotation(pin)
        }
        print("Волонтеры расположены на карте!")
        
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
