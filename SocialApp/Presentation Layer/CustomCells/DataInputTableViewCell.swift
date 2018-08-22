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

    @IBOutlet weak var numberTextField: IsaoTextField!
    
    @IBOutlet weak var passTextField: IsaoTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    weak var delegate: CustomCellsActionsDelegate?
    private var currentTextField: IsaoTextField?
    var userType: LogState = LogState.inv
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberTextField.delegate = self
        numberTextField.keyboardType = .phonePad
        passTextField.delegate = self
    
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
        
        //request building.
        // Starting with finding data
        guard let userNumber = numberTextField.text else {return}
        guard let userPassword = passTextField.text else {return}
        
        switch userType {
        case .inv:
            APIClient.invLogin(id: userNumber, password: userPassword){ (responseObject, error) in
                
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "signIn"{
                        let name = responseObject?.value(forKey: "name") as! String
                        SCLAlertView().showSuccess("Здравствуйте, \(name)!", subTitle: "Продолжите работу.")
                        // create User Profile here! Save it to core data async.
                        // call for the next view after it.
                        self.delegate?.readyToShowGeoView()
                        
                    } else if status == "not in db"{
                        SCLAlertView().showError("Повторите вход", subTitle: "Пользователь не найден")
                    } else if status == "bad pass"{
                        SCLAlertView().showError("Неверный пароль", subTitle: "Введите пароль еще раз")
                    } else {
                        print("some strange status handled!\n\(status)")
                    }
                } else {
                    if let e = error{
                        print(e.localizedDescription)
                        SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.")
                    }
                }
            }
        case .vol:
            
            APIClient.volLogin(number: userNumber, password: userPassword) { (responseObject, error) in
                
                if error == nil {
                    let status = responseObject?.value(forKey: "resp") as! String
                    if status == "signIn"{
                        let name = responseObject?.value(forKey: "name") as! String
                        SCLAlertView().showSuccess("Здравствуйте, \(name)!", subTitle: "Продолжите работу.")
                        // create User Profile here! Save it to core data async.
                        // call for the next view after it.
                        self.delegate?.readyToShowGeoView()
                    } else if status == "not in db"{
                        SCLAlertView().showError("Повторите вход", subTitle: "Пользователь не найден")
                    } else if status == "bad pass"{
                        SCLAlertView().showError("Неверный пароль", subTitle: "Введите пароль еще раз")
                    } else {
                        print("some strange status handled!\n\(status)")
                    }
                } else {
                    if let e = error{
                      print(e.localizedDescription)
                      SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.")
                    }
                }
            }
        }
    }
    
    @IBAction func moveToRegistrationTapped(_ sender: UIButton) {
        if let currentTextField = currentTextField {
            currentTextField.resignFirstResponder()
        }
        
        // setting up button to be without build-in "Done" button
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        switch userType {
        case .inv:
            let alert = SCLAlertView(appearance: appearance)
            let idTextField = alert.addTextField("ID")
            let nameTextField = alert.addTextField("Ваше имя")
            let numberTextField = alert.addTextField("Номер телефона")
            numberTextField.keyboardType = .phonePad
            let passTextField = alert.addTextField("Пароль")
            alert.addButton("Готово") {
                // check all of the rows for normal data TODO!!!!
                print("data from rows is loaded")
                guard let userID = idTextField.text else {return}
                guard let userName = nameTextField.text else {return}
                guard let userNumber = numberTextField.text else {return}
                guard let userPassword = passTextField.text else {return}
                APIClient.invRegistrate(id: userID, name: userName, number: userNumber, password: userPassword, completion: { (responseObject, error) in
                    
                    if error == nil {
                        let status = responseObject?.value(forKey: "resp") as! String
                        if status == "signUP"{
                            SCLAlertView().showSuccess("Регистрация прошла успешно", subTitle: "Теперь вы можете войти в систему!")
                        } else if status == "in db"{
                            SCLAlertView().showError("Ошибка регистрации", subTitle: "Пользователь с такими данными уже найден. Произведите вход в систему.")
                        } else {
                            print("some strange status handled!\n\(status)")
                        }
                    } else {
                        if let e = error{
                            print(e.localizedDescription)
                            // handle more errors here TODO!
                            SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.")
                        }
                    }
                })
                
            }
            alert.showEdit("Зарегестрируйтесь!", subTitle: "Заполните все поля")
        case .vol:
            let alert = SCLAlertView(appearance: appearance)
            let nameTextField = alert.addTextField("Ваше имя")
            let numberTextField = alert.addTextField("Номер телефона")
            numberTextField.keyboardType = .phonePad
            let passTextField = alert.addTextField("Пароль")
            alert.addButton("Готово!"){
                // check all of the rows for normal data TODO!!!!
                guard let userName = nameTextField.text else {return}
                guard let userNumber = numberTextField.text else {return}
                guard let userPassword = passTextField.text else {return}
                print("data from rows is loaded")
                APIClient.volRegistrate(name: userName, number: userNumber, password: userPassword){ (responseObject, error) in
                    
                    if error == nil {
                        let status = responseObject?.value(forKey: "resp") as! String
                        if status == "signUP"{
                            SCLAlertView().showSuccess("Регистрация прошла успешно", subTitle: "Теперь вы можете войти в систему!")
                        } else if status == "in db"{
                            SCLAlertView().showError("Ошибка регистрации", subTitle: "Пользователь с такими данными уже найден. Произведите вход в систему.")
                        } else {
                            print("some strange status handled!\n\(status)")
                        }
                    } else {
                        if let e = error{
                            print(e.localizedDescription)
                            // handle more errors here TODO!
                            SCLAlertView().showError("Нет соединения с сервером!", subTitle: "Проверьте соединение с интернетом.")
                        }
                    }
                }
            }
            alert.showEdit("Зарегестрируйтесь!", subTitle: "Заполните все поля")
        }
        print("move to registration page")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
