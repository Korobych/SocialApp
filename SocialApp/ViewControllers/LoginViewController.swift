//
//  LoginViewController.swift
//  SocialApp
//
//  Created by Sergey Korobin on 03.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var titleString: String?
    private var loginTableView: UITableView!
    private let myArray: Array = ["Vk/Twitter/Facebook"]
    
    // enum state inv/vol
    public enum LogState {
        case inv
        case vol
    }
    
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
        // setting up button click
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            return myArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = Bundle.main.loadNibNamed("SocialTableViewCell", owner: self, options: nil)?.first as! SocialTableViewCell
            return cell
        } else if indexPath.section == 1{
            let cell = Bundle.main.loadNibNamed("DataInputTableViewCell", owner: self, options: nil)?.first as! DataInputTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
            cell.textLabel!.text = "\(myArray[indexPath.row])"
            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginViewController{
    
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
