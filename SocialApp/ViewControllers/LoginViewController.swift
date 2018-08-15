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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavingationBar()
        setUpTableView()
        loginTableView.dataSource = self
        loginTableView.delegate = self
        
        
    }
    
    // handling hit on Back BarItem and adding smooth animation of it's moving away
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    // ********************
    // tableView setting up
    // ********************
    
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
    
    // Заканчивать редактирование текстового поля при нажатии в "пустоту"
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    func setUpNavingationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = titleString
    }
    
    func setUpTableView(){
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        loginTableView = UITableView(frame: CGRect(x: 0, y: self.topDistance + 40.0, width: displayWidth, height: displayHeight - self.topDistance - 40.0))
        loginTableView.isScrollEnabled = false
        loginTableView.separatorStyle = .none
        loginTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.view.addSubview(loginTableView)
    }
}
