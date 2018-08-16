//
//  LoginViewController.swift
//  SocialApp
//
//  Created by Sergey Korobin on 03.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit

// enum state inv/vol
enum LogState {
    case inv
    case vol
}

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var titleString: String?
    private var loginTableView: UITableView!
    var userType: LogState = LogState.inv
    var keyboardOnScreen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavingationBar()
        setUpTableView()
        loginTableView.dataSource = self
        loginTableView.delegate = self
        // added keyboard observers also delete them!!! to do
        addKeyboardObservers()
        
    }
    
    // handling hit on Back BarItem and adding smooth animation of it's moving away
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            removeKeyboardObservers()
        }
    }
    // ********************
    // tableView setting up
    // ********************
    
    // implement logic when touch on any cell in tableView -> close keyboard
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch userType {
        case .inv:
            return 1
        case .vol:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch userType {
        case .inv:
            let cell = Bundle.main.loadNibNamed("DataInputTableViewCell", owner: self, options: nil)?.first as! DataInputTableViewCell
            return cell
        case .vol:
            if indexPath.section == 0{
                let cell = Bundle.main.loadNibNamed("SocialTableViewCell", owner: self, options: nil)?.first as! SocialTableViewCell
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("DataInputTableViewCell", owner: self, options: nil)?.first as! DataInputTableViewCell
                return cell
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginViewController{
    
    func addKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if !self.keyboardOnScreen{
            if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y -= keyboardHeight/3
                self.keyboardOnScreen = true
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y += keyboardHeight/3
            self.keyboardOnScreen = false
        }
    }
    
    func setUpNavingationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = titleString
    }
    
    func setUpTableView(){
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // handle background view touch
        let tap = UITapGestureRecognizer(target: self, action: #selector(outsideTableTapped))
        
        loginTableView = UITableView(frame: CGRect(x: 0, y: self.topDistance + 40.0, width: displayWidth, height: displayHeight - self.topDistance - 40.0))
        loginTableView.isScrollEnabled = false
        loginTableView.separatorStyle = .none
        loginTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // case with tapping in clear part of UITableView (without cells)
        //
        loginTableView.backgroundView = UIView()
        loginTableView.addGestureRecognizer(tap)
        //
        self.view.addSubview(loginTableView)
    }
    
    // close keyboard and stop editing TextField
    @objc func outsideTableTapped(tap:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
