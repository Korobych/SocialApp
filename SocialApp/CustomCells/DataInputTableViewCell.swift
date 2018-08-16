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
        //
//        let userLoginModel: VolLog = VolLog(number: userNumber, password: userPassword)
        let parameters: Parameters = [
            "number" : userNumber,
            "password" : userPassword
        ]
        
        Alamofire.request("http://localhost:3005/vol/in", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                if utf8Text == "{\"resp\":\"not in db\"}" {
                    SCLAlertView().showError("Повторите вход", subTitle: "Пользователь не найден")
                } else if utf8Text == "{\"resp\":\"signIN\"}"{
                    SCLAlertView().showSuccess("Вход прошел удачно", subTitle: "Продолжите работу")
                }
                print("Data: \(utf8Text)") // original server data as UTF8 string
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
                // check all of the rows for normal data
                print("load data from rows")
            }
            alert.showEdit("Зарегестрируйтесь!", subTitle: "Заполните все поля")
        case .vol:
            let alert = SCLAlertView(appearance: appearance)
            let nameTextField = alert.addTextField("Ваше имя")
            let numberTextField = alert.addTextField("Номер телефона")
            numberTextField.keyboardType = .phonePad
            let passTextField = alert.addTextField("Пароль")
            alert.addButton("Готово!"){
                // check all of the rows for normal data
                print("load data from rows")
                
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
