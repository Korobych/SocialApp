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
    // In code volUserModel keeping from vol/geolist API query.
    // | //
    // ↓ //
    var volData: [VolUserModel] = []
    // Variables for keeping vol and user data in case it's transaction to them.
    // | //
    // ↓ //
    var chosenInvData: InvUserModel!
    var chosenVolData: VolUserModel!
    // Timers
    // | //
    // ↓ //
    var volDataUpdateTimer: Timer?
    var localUserGeoUpdateTimer: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var conidVerifyButton: UIButton!
    @IBOutlet weak var conidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setupMidButton()
        setupConidLabel()
        setupReloadButton()
        setupConidVerifyButton()
        
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
    
    
    @IBAction func conidVerifyButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Вы почти у цели!", message: "Введите номер, сообщенный собеседником.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "ОК", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            // handle conid sending here
            guard let conid = textField.text else {return}
            if conid != ""{
                APIClient.volGetInv(phone: self.currentProfile.phone, conid: conid, completion: { (responseObject, error) in
                    if error == nil {
                        let status = responseObject?.value(forKey: "resp") as! String
                        if status == "nice"{
                            print("\nУспешная связь между инволидом и волонтером!\n")
                            // parse data to new chosenInvData
                            let name = responseObject?.value(forKey: "name") as! String
                            let phone = responseObject?.value(forKey: "phone") as! String
                            let geoData = responseObject?.value(forKey: "geo") as! NSArray
                            // Bad things going on here REWRITE
                            // -------------------------------
                            guard let lat = geoData[0] as? String else {return}
                            guard let long = geoData[1] as? String else {return}
                            
                            let latDouble = Double(lat)!
                            let longDouble = Double(long)!
                            // -------------------------------
                            self.chosenInvData = InvUserModel(id: "", name: name, latitude: latDouble, longitude: longDouble, phone: phone)
                            // show him on map
                            self.drawCurrentInvPin(inv: self.chosenInvData)
                            // TODO: make a road to this pin.
                            
                            // hide conid verification button
                            self.conidVerifyButton.isEnabled = false
                            UIView.animate(withDuration: 1, animations: {
                                self.conidVerifyButton.alpha = 0.0
                            })
                            SCLAlertView().showSuccess("Спешите на помощь", subTitle: "Инвалид уже ждет Вас", closeButtonTitle: "ОК")
                            
                            
                        } else if status == "vol not found"{
                            print("\nОшибка! Такой волонтер не найден!\n")
                        } else if status == "vol not ready" {
                            print("\nОшибка! Волонтер не готов помогать!\n")
                        } else if status == "bad conid" {
                            print("\nОшибка! Неверный conid!\n")
                        } else if status == "bad inv find"{
                            print("\nОшибка! bad inv find!\n")
                        } else if status == "user not found"{
                            print("\nОшибка! inv not found!\n")
                        } else if status == "busy"{
                            SCLAlertView().showError("Ошибка", subTitle: "Один из вас имеет статус: Занят!", closeButtonTitle: "ОК")
                            print("\nОшибка! Волонтер и инволид уже заняты!\n")
                        } else if status == "bad inv set"{
                            print("\nОшибка! bad inv set!\n")
                        } else if status == "bad vol set"{
                            print("\nОшибка! bad vol set!\n")
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
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Номер собеседника..."
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func locationManagerCustomSetup(){
        
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
            // TODO: fix CH/ND touch with state = 1
            // if still in app after login, but without geo - we should let person leave the app -> back and send Ch/Nh
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
        navigationItem.title = "Social App"
        navigationItem.setHidesBackButton(true, animated: false)
        // setting right NavBar button (exit)
        let exitButton = UIButton(type: .custom)
        exitButton.setImage(#imageLiteral(resourceName: "logOut_pic"), for: .normal)
        exitButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        exitButton.contentMode = .scaleAspectFit
        let rightBarItem = UIBarButtonItem(customView: exitButton)
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func logOut() {
        
        // Logic with exit from account
        DispatchQueue.main.async {
            let exitAlert = UIAlertController(title: "Вы собираетесь выйти из текущего аккаунта!", message: "Уверены, что точно хотите этого?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: "Да", style: .default){ action in
                
                let goodExitAlert = UIAlertController(title: "Вы успешно вышли.", message: "Ждем Вас снова 😁!", preferredStyle: UIAlertControllerStyle.alert)
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
        menuButton.addTarget(self, action: #selector(midButtonAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
        self.view.layoutIfNeeded()
    }
    
    func setupReloadButton(){
        reloadButton.clipsToBounds = true
        reloadButton.layer.cornerRadius = reloadButton.frame.height/2
        reloadButton.setImage(#imageLiteral(resourceName: "reload_pic"), for: .normal)
        reloadButton.contentMode = .scaleAspectFit
        reloadButton.tintColor = UIColor.gray
        reloadButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        reloadButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        reloadButton.alpha = 0.0
        reloadButton.isEnabled = false
    }
    
    func setupConidLabel(){
        conidLabel.clipsToBounds = true
        conidLabel.layer.cornerRadius = self.conidLabel.frame.height/3
        conidLabel.backgroundColor = #colorLiteral(red: 0.2202436289, green: 0.7672206565, blue: 0.5130995929, alpha: 0.789625671)
        conidLabel.tintColor = UIColor.white
        conidLabel.text = ""
        conidLabel.alpha = 0.0
        conidLabel.isEnabled = false
    }
    
    func setupConidVerifyButton(){
        conidVerifyButton.clipsToBounds = true
        conidVerifyButton.layer.cornerRadius = conidVerifyButton.frame.height/2
        conidVerifyButton.setImage(#imageLiteral(resourceName: "conidVerify_pic"), for: .normal)
        conidVerifyButton.contentMode = .scaleAspectFit
        conidVerifyButton.tintColor = UIColor.gray
        conidVerifyButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        conidVerifyButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        conidVerifyButton.alpha = 0.0
        conidVerifyButton.isEnabled = false
    }
    
    // show conid label view to inv
    func showConidLabel(conid: String){
        if conid != "" {
            self.conidLabel.text = "Назовите номер: \(conid)"
            UIView.animate(withDuration: 1.5) {
                self.conidLabel.alpha = 1.0
            }
            
            UIView.animate(withDuration: 1.0, delay:0, options: [.repeat, .autoreverse], animations: {
                UIView.setAnimationRepeatCount(3)
                self.conidLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                
            }, completion: {completion in
                UIView.animate(withDuration: 1, animations: {
                    self.conidLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
            self.conidLabel.isEnabled = true
        }
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
                        // show conidButton with animation!
                        self.conidVerifyButton.isEnabled = true
                        UIView.animate(withDuration: 1.5, animations: {
                            self.conidVerifyButton.alpha = 1.0
                        })
                        print("\nКнопка верификации conid отрисована!\n")

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
                        self.showConidLabel(conid: status)
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
    
    func drawCurrentInvPin(inv: InvUserModel){
        let pin = CustomPin(title: inv.name, subtitle: inv.phone, coordinate: CLLocationCoordinate2DMake(inv.latitude, inv.longitude))
        self.mapView.addAnnotation(pin)
        print("Найденный инволид размещен на карте!")
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
