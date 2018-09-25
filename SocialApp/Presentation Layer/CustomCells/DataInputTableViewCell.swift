//
//  DataInputTableViewCell.swift
//  SocialApp
//
//  Created by Sergey Korobin on 15.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit
import TextFieldEffects
import SCLAlertView
import Alamofire

class DataInputTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var phoneTextField: IsaoTextField!
    
    @IBOutlet weak var passTextField: IsaoTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    weak var delegate: CustomCellsActionsDelegate?
    private var currentTextField: IsaoTextField?
    var userType: LogState = LogState.inv
    // hotfix | better to move this logic to LoginViewController
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    // later
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileManager.delegate = self
        phoneTextField.delegate = self
        passTextField.delegate = self
        setupNotEmptyTextFields()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField as? IsaoTextField
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let currentTextField = currentTextField {
            currentTextField.resignFirstResponder()
        }
        
        // request building.
        // Starting with getting data
        guard let userNumber = phoneTextField.text else {return}
        guard let userPassword = passTextField.text else {return}
        
        switch userType {
        case .inv:
            APIClient.invLogin(id: userNumber, password: userPassword){ (responseObject, error) in
                if self.loginResponseHandler(responseObject: responseObject, error: error){
                    // delegate it?
                    let userName = responseObject?.value(forKey: "name") as! String
                    let userPhone = responseObject?.value(forKey: "phone") as! String
                    print(userPhone)
                    //create INV !!! User Profile here! Save it to core data async.
                    self.profileManager.saveInvProfile(id: userNumber, name: userName, phone: userPhone, password: userPassword, photo: nil)
                    // clean textFields after successful login
                    self.phoneTextField.text = ""
                    self.passTextField.text = ""
                    // call for the next view after it.
                    self.delegate?.readyToShowGeoView()
                }
            }
        
        case .vol:
            
            APIClient.volLogin(phone: userNumber, password: userPassword) { (responseObject, error) in
                if self.loginResponseHandler(responseObject: responseObject, error: error) {
                    // delegate it?
                    let userName = responseObject?.value(forKey: "name") as! String
                    //create VOL !!! User Profile here! Save it to core data async.
                    self.profileManager.saveVolProfile(name: userName, phone: userNumber, password: userPassword, photo: nil)
                    // clean textFields after successful login
                    self.phoneTextField.text = ""
                    self.passTextField.text = ""
                    // call for the next view after it.
                    self.delegate?.readyToShowGeoView()
                }

            }
        }
    }
    
    @IBAction func moveToRegistrationTapped(_ sender: UIButton) {
        if let currentTextField = currentTextField {
            currentTextField.resignFirstResponder()
        }
        
        switch userType {
        case .inv:
            let alert = SCLAlertView()
            let idTextField = alert.addTextField("ID")
            let nameTextField = alert.addTextField("Ваше имя")
            let phoneTextField = alert.addTextField("Номер телефона")
            phoneTextField.keyboardType = .phonePad
            let passTextField = alert.addTextField("Пароль")
            alert.addButton("Готово") {
                // check all rows and delete whitespaces from strings
                guard let userID = idTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                guard let userName = nameTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                guard let userNumber = phoneTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                guard let userPassword = passTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                // -------------------------------------------------------------
                // checking for empty TextFields in registration alert
                if userID.isEmpty || userName.isEmpty || userNumber.isEmpty || userPassword.isEmpty{
                    
                    SCLAlertView().showError("Неверно введены данные!", subTitle: "Все строки должны быть заполненны!", closeButtonTitle: "ОК")
                } else {
                    APIClient.invRegistrate(id: userID, name: userName, phone: userNumber, password: userPassword, completion: { (responseObject, error) in
                        
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "signUP"{
                                SCLAlertView().showSuccess("Регистрация прошла успешно", subTitle: "Теперь вы можете войти в систему!", closeButtonTitle: "ОК")
                            } else if status == "in db"{
                                SCLAlertView().showError("Ошибка регистрации", subTitle: "Пользователь с введенным ID уже существует. Произведите вход в систему.", closeButtonTitle: "ОК")
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
            alert.showEdit("Зарегестрируйтесь!", subTitle: "Заполните все поля.", closeButtonTitle: "Закрыть")
        case .vol:
            let alert = SCLAlertView()
            let nameTextField = alert.addTextField("Ваше имя")
            let phoneTextField = alert.addTextField("Номер телефона")
            let passTextField = alert.addTextField("Пароль")
            alert.addButton("Готово!"){
                // check all rows and delete whitespaces from strings
                guard let userName = nameTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                guard let userNumber = phoneTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                guard let userPassword = passTextField.text?.trimmingCharacters(in: .whitespaces) else {return}
                // -------------------------------------------------------------
                // checking for empty TextFields in registration alert
                if userName.isEmpty || userNumber.isEmpty || userPassword.isEmpty {
                    
                    SCLAlertView().showError("Неверно введены данные!", subTitle: "Все строки должны быть заполненны!", closeButtonTitle: "ОК")
                    
                } else {
                    APIClient.volRegistrate(name: userName, phone: userNumber, password: userPassword){ (responseObject, error) in
                        
                        if error == nil {
                            let status = responseObject?.value(forKey: "resp") as! String
                            if status == "signUP"{
                                SCLAlertView().showSuccess("Регистрация прошла успешно", subTitle: "Теперь вы можете войти в систему!", closeButtonTitle: "ОК")
                            } else if status == "in db"{
                                SCLAlertView().showError("Ошибка регистрации", subTitle: "Пользователь с введённым Телефонным номером уже существует. Произведите вход в систему.", closeButtonTitle: "ОК")
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
            alert.showEdit("Зарегестрируйтесь!", subTitle: "Заполните все поля.", closeButtonTitle: "Закрыть")
        }
        print("move to registration page")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DataInputTableViewCell {
    
    // Login response handler
    func loginResponseHandler(responseObject : NSDictionary?, error: Error?) -> Bool{
        if error == nil {
            let status = responseObject?.value(forKey: "resp") as! String
            if status == "signIn" || status == "comeback"{
//                let name = responseObject?.value(forKey: "name") as! String
                // ---------------------------------------------
                // Welcome alert with the logic of name handling
//                SCLAlertView().showSuccess("Здравствуйте, \(name)!", subTitle: "Приятного пользования приложением.", closeButtonTitle: "Ура")
                return true
                
            } else if status == "not in db"{
                SCLAlertView().showError("Повторите вход", subTitle: "Пользователь не найден", closeButtonTitle: "ОК")
                return false
            } else if status == "bad pass"{
                SCLAlertView().showError("Неверный пароль", subTitle: "Введите пароль еще раз", closeButtonTitle: "ОК")
                return false
            } else {
                print("some strange status handled!\n\(status)")
                return false
            }
        } else {
            if let e = error{
                print(e.localizedDescription)
                SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.", closeButtonTitle: "ОК")
            }
            return false
        }
    }
    
    // checking for whitespaces or empty text of login TextFields
    func setupNotEmptyTextFields() {
        loginButton.isEnabled = false
        phoneTextField.addTarget(self, action: #selector(loginEditingChanged),
                                  for: .editingChanged)
        passTextField.addTarget(self, action: #selector(loginEditingChanged),
                                for: .editingChanged)
        passTextField.addTarget(self, action: #selector(loginEditingChanged),
                                for: .editingDidBegin)
    }
    
    @objc func loginEditingChanged(_ textField: UITextField){
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {return}
        if !text.isEmpty{
            self.loginButton.isEnabled = true
        } else {
            self.loginButton.isEnabled = false
        }
    }
}

extension DataInputTableViewCell: ProfileManagerDelegateProtocol{

    func didFinishSave(success: Bool) {
        if success{
            print("\nПользователь удачно сохранен в локальную память!\n")
        }
    }

    func didFinishDeleting(success: Bool) {
        // do nothing here
    }
    
    func didFinishReading(profile: Profile) {
        // do nothing here
    }
    
}
