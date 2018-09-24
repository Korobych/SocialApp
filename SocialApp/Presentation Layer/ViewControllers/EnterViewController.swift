//
//  ViewController.swift
//  SocialApp
//
//  Created by Sergey Korobin on 01.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit

class EnterViewController: UIViewController {
    
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    
    @IBOutlet weak var wantToHelpButton: UIButton!
    @IBOutlet weak var needHelpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileManager.delegate = self
        profileManager.getProfileInfo()
        setCustomBackgroundImage()
        setUpButtons(upper: wantToHelpButton, lower: needHelpButton)
    }
    
    // Functions for programmatical segue to LoginViewController
    @objc func wantToHelpButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "LogRegController") as! LoginViewController
        // send data here
        nextViewController.titleString = "Войдите, чтобы помочь"
        nextViewController.userType = LogState.vol
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }
    
    @objc func needHelpButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "LogRegController") as! LoginViewController
        // send data here
        nextViewController.titleString = "Войдите и Вам помогут"
        nextViewController.userType = LogState.inv
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension EnterViewController{
    func setUpButtons(upper: UIButton, lower: UIButton){
        upper.clipsToBounds = true
        lower.clipsToBounds = true
        upper.layer.cornerRadius = 0.5 * upper.bounds.size.width
        upper.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        lower.layer.cornerRadius = 0.5 * lower.bounds.size.width
        lower.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        upper.addTarget(self, action: #selector(wantToHelpButtonTapped),
                         for: .touchUpInside)
        lower.addTarget(self, action: #selector(needHelpButtonTapped),
                        for: .touchUpInside)
        
    }
}

extension EnterViewController: ProfileManagerDelegateProtocol{
    func didFinishSave(success: Bool) {
        // do nothing here
    }
    
    func didFinishDeleting(success: Bool) {
        // do nothing here
    }
    func didFinishReading(profile: Profile) {
        print("Профиль из локальной памяти удачно загружен!")
        if profile.invId == "" {
            wantToHelpButtonTapped()
        } else {
            needHelpButtonTapped()
        }
    }
    
}

//Background on any ViewController
extension UIViewController{
    func setCustomBackgroundImage(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg_img.jpg")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    public var topDistance : CGFloat{
        get{
            if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                return 0
            }else{
                let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                return barHeight + statusBarHeight
            }
        }
    }
}

