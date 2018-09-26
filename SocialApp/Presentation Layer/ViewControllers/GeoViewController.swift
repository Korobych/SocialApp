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
    var helperInfoGetTimer: Timer?
    var helperGeoGetTimer: Timer?
    
    var conId: String!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var conidVerifyButton: UIButton!
    @IBOutlet weak var stopHelpButton: UIButton!
    @IBOutlet weak var conidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setupMidButton()
        setupConidLabel()
        setupReloadButton()
        setupConidVerifyButton()
        setupStopHelpButton()
        
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
                        if status == "nice" || status == "vol recovery"{
                            print("\nУспешная связь между инвалидом и волонтером!\n")
                            // parse data to new chosenInvData
                            let name = responseObject?.value(forKey: "name") as! String
                            let phone = responseObject?.value(forKey: "phone") as! String
                            let geoData = responseObject?.value(forKey: "geo") as! NSArray
                            // TODO: Bad things going on here REWRITE
                            // -------------------------------
                            guard let lat = geoData[0] as? String else {return}
                            guard let long = geoData[1] as? String else {return}
                            
                            let latDouble = Double(lat)!
                            let longDouble = Double(long)!
                            // -------------------------------
                            self.chosenInvData = InvUserModel(id: "", name: name, latitude: latDouble, longitude: longDouble, phone: phone)
                            // show him on map
                            self.drawCurrentInvPin(inv: self.chosenInvData)
    
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
                            print("\nОшибка! Волонтер и инвалид уже заняты!\n")
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
    
    
    @IBAction func stopHelpButtonTapped(_ sender: UIButton) {
        // setting up uialert sheets
        let stopHelpAlert = UIAlertController(title: "Завершить сессию?", message: "Укажите состояние", preferredStyle: UIAlertControllerStyle.actionSheet)
        let okButton = UIAlertAction(title: "Мне помогли", style: .default) { (alert) in
            
            print("Хорошее завершение сессии")
            
            let ratingAlert = UIAlertController(title: "Оцените помощь волонтера", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let goodButton = UIAlertAction(title: "Хорошо", style: .default) { (alert) in
                // good send
                self.stopHelp(review: "good")
            }
            let badButton = UIAlertAction(title: "Плохо", style: .destructive) { (alert) in
                // bad send
                self.stopHelp(review: "bad")
            }
            ratingAlert.addAction(goodButton)
            ratingAlert.addAction(badButton)
            self.present(ratingAlert, animated: true, completion: nil)
            
        }
        let dropButton = UIAlertAction(title: "Помощь больше не нужна", style: .destructive) { (alert) in
            self.stopHelp(review: "none")
            print("Дроп со стороны инвалида")
        }
        let deleteButton = UIAlertAction(title: "Отмена. Верните меня обратно", style: .cancel) { (alert) in
            print("missclick")
        }
        
        stopHelpAlert.addAction(okButton)
        stopHelpAlert.addAction(dropButton)
        stopHelpAlert.addAction(deleteButton)
        
        self.present(stopHelpAlert, animated: true, completion: nil)
    }
    
    @objc func locationManagerCustomSetup(){
        
        if CLLocationManager.locationServicesEnabled(){
            didGetFirstLocation = false
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
            mapView.showsScale = true
            mapView.showsCompass = true
            mapView.alpha = 1.0
            mapView.showsUserLocation = true
            
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
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
            // saving current geo(lat, long) to code
            self.currentLocation = [lat, long]
            
            if !self.didGetFirstLocation {
                print("Координаты: \(lat),\(long)\n")
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
    
    // **************************
    // MkAnnotation setting up
    // **************************
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = CustomVolAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "userPin_pic")
        return annotationView

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation
        {
            return
        }
        
        // TODO: Not empty or nill content inside annotation
        let userAnnotation = view.annotation as! CustomPin
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.nameLabel.text = userAnnotation.title
        calloutView.phoneLabel.text = userAnnotation.subtitle
        let button = UIButton(frame: calloutView.callButton.frame)
        button.addTarget(self, action: #selector(callPhoneNumber(sender:)), for: .touchUpInside)
        calloutView.addSubview(button)
      
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomVolAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
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
                        if self.helperInfoGetTimer != nil{
                            self.helperInfoGetTimer?.invalidate()
                        }
                        if self.helperGeoGetTimer != nil{
                            self.helperGeoGetTimer?.invalidate()
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
    
    func setupStopHelpButton(){
        stopHelpButton.clipsToBounds = true
        stopHelpButton.layer.cornerRadius = stopHelpButton.frame.height/2
        stopHelpButton.setImage(UIImage(named: "stopHelp_pic"), for: .normal)
        stopHelpButton.contentMode = .scaleAspectFit
        stopHelpButton.tintColor = UIColor.white
        stopHelpButton.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        stopHelpButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        stopHelpButton.alpha = 0.0
        stopHelpButton.isEnabled = false
    }
    
    
    // show conid label view to inv
    func showConidLabel(conid: String){
        if conid != "" {
            self.conidLabel.text = "Назовите номер: \(conid)"
            UIView.animate(withDuration: 1) {
                self.conidLabel.alpha = 1.0
            }
            
            UIView.animate(withDuration: 1.0, delay:0, options: [.repeat, .autoreverse], animations: {
                UIView.setAnimationRepeatCount(3)
                self.conidLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
            }, completion: {completion in
                UIView.animate(withDuration: 1, animations: {
                    self.conidLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
            self.conidLabel.isEnabled = true
        }
    }
    
    func hideConidLabel(){
        UIView.animate(withDuration: 1) {
            self.conidLabel.alpha = 0.0
        }
        conidLabel.isEnabled = false
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
                                        } else {
                                            print("some strange status \(status)")
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
                        self.conId = status
                        self.loadVolPins()
                        self.showConidLabel(conid: status)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)

                        // timer to update set up!  --- selected time is 120 secs
                        DispatchQueue.main.async {
                            self.volDataUpdateTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
                                // clear map from previous annotations
                                // TODO: make smarter delete fucntion. If the geo diff is less than const, don't delete it.
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
                                        } else {
                                            print("some strange status \(status)")
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
                            // add timer for getting helperInfo
                            self.helperInfoTimer()
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
                    // TODO: Bad things going on here REWRITE
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
        // added logic with reentering the app
        self.mapView.removeAnnotations(self.mapView.annotations)
        if self.chosenVolData != nil{
            let pin = CustomPin(title: self.chosenVolData.name, subtitle: self.chosenVolData.phone, coordinate: CLLocationCoordinate2DMake(self.chosenVolData.latitude, self.chosenVolData.longitude))
            self.mapView.addAnnotation(pin)
        } else{
            for user in self.volData{
                if user.status == 2{
                    guard let vol = self.chosenVolData else {return}
                    if user.name == vol.name && user.phone == vol.phone {
                        let pin = CustomPin(title: user.name, subtitle: user.phone, coordinate: CLLocationCoordinate2DMake(user.latitude, user.longitude))
                        self.mapView.addAnnotation(pin)
                        break
                    }
                }
                if user.status == 1{
                    let pin = CustomPin(title: user.name, subtitle: user.phone, coordinate: CLLocationCoordinate2DMake(user.latitude, user.longitude))
                    self.mapView.addAnnotation(pin)
                }
            }
            print("Волонтеры расположены на карте!")
        }
        
    }
    
    func helperInfoTimer(){
        // detect that current user = inv and start timer (waiting for vol info)
        if self.currentProfile.invId != ""{
            if self.helperGeoGetTimer == nil{
                self.helperInfoGetTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    APIClient.helperInfo(id: self.currentProfile.invId , completion: { (responseObject, error) in
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "bad"{
                                // TODO: alert after a few timer firing, telling the user not to wait for the phoned vol. And search for another one
                                print("Помощь все еще не найдена.")
                            } else if status == "true" {
                                print("Волонтер найден!")
                                self.hideConidLabel()
                                SCLAlertView().showSuccess("Волонтер подтвердил помощь", subTitle: "Ожидайте волонтера. Следите за его передвижением на карте.", closeButtonTitle: "ОК")
                                let name = responseObject?.value(forKey: "name") as! String
                                let phone = responseObject?.value(forKey: "phone") as! String
                                let latitude = responseObject?.value(forKey: "latitude") as! String
                                let longitude = responseObject?.value(forKey: "longitude") as! String
                                
                                guard let latDouble = Double(latitude) else {return}
                                guard let longDouble = Double(longitude) else {return}
                                // FIXIT: we already have data in volUserModel, better to filter it and get chosen vol.
                                let chosenVol = VolUserModel(name: name, phone: phone, latitude: latDouble, longitude: longDouble, status: 2)
                                self.chosenVolData = chosenVol
                                self.drawVolPins()
                                // we don't need this timer anymore -> exetung chosen user geo data update timer (to be done)
                                self.helperInfoGetTimer?.invalidate()
                                self.helperGeoTimer()
                                
                                // show stopHelpButton with animation!
                                self.stopHelpButton.isEnabled = true
                                UIView.animate(withDuration: 1, animations: {
                                    self.stopHelpButton.alpha = 1.0
                                })
                                print("\nКнопка stopHelp отрисована!\n")
                            } else {
                                print("strange status \(status)")
                            }
                        } else {
                            if let e = error{
                                print(e.localizedDescription)
                                // handle more errors here TODO!
                                SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                            }
                        }
                    })
                })
            }
        }
    }
    
    func helperGeoTimer(){
        // detect that current user = inv and start timer (waiting for vol GEO)
        if self.currentProfile.invId != ""{
            if self.helperGeoGetTimer == nil {
                self.helperGeoGetTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in
                    APIClient.helperGeo(id: self.currentProfile.invId, completion: { (responseObject, error) in
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "bad"{
                                print("\nОшибка! Неуспешная попытка обновить геопозицию привязанного волонтера! inv\n")
                            } else if status == "nice" {
                                // TODO: bad things. rewrite
                                let latitude = responseObject?.value(forKey: "latitude") as! String
                                let longitude = responseObject?.value(forKey: "longitude") as! String
                                
                                guard let latDouble = Double(latitude) else {return}
                                guard let longDouble = Double(longitude) else {return}
                                guard var vol = self.chosenVolData else {return}
                                vol.latitude = latDouble
                                vol.longitude = longDouble
                                self.drawCurrentVolPin(vol: vol)
                                print("\nГеоданные привязанного волонтера обновлены.\n")
                            } else {
                                print("some strange status \(status)")
                            }
                        } else {
                            if let e = error{
                                print(e.localizedDescription)
                                // handle more errors here TODO!
                                SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
                            }
                        }
                    })
                })
            }
        }
    }
    
    func drawCurrentInvPin(inv: InvUserModel){
        // clear all pins if needed
        let pin = CustomPin(title: inv.name, subtitle: inv.phone, coordinate: CLLocationCoordinate2DMake(inv.latitude, inv.longitude))
        self.mapView.addAnnotation(pin)
        print("Найденный инвалид размещен на карте!")
    }
    
    func drawCurrentVolPin(vol: VolUserModel){
        // clear all pins if needed
        self.mapView.removeAnnotations(self.mapView.annotations)
        let pin = CustomPin(title: vol.name, subtitle: vol.phone, coordinate: CLLocationCoordinate2DMake(vol.latitude, vol.longitude))
        self.mapView.addAnnotation(pin)
        print("Найденный волонтер размещен на карте!")
    }

    @objc func callPhoneNumber(sender: UIButton)
    {
        let v = sender.superview as! CustomCalloutView
        if let url = URL(string: "telprompt://\(v.phoneLabel.text!)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func stopHelp(review: String){
        if self.currentProfile.invId != "" {
            APIClient.invStopHelp(conid: self.conId, phone: self.chosenVolData.phone, review: review) { (responseObject, error) in
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "true"{
                        print("\nУспешное завершение сессии!\n")
                        // hide stopHelp button + stop helperGeoGetTimer and localUserGeoUpdateTimer + clear annotations + self.chosenVol clear
                        self.helperGeoGetTimer?.invalidate()
                        self.localUserGeoUpdateTimer?.invalidate()
                        self.chosenVolData = nil
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.stopHelpButton.isEnabled = false
                        UIView.animate(withDuration: 1, animations: {
                            self.stopHelpButton.alpha = 0.0
                        })
                    } else if status == "false"{
                        print("\nОшибка! Не удалось закончить сессию!\n")
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
