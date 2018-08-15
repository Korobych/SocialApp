//
//  DataInputTableViewCell.swift
//  SocialApp
//
//  Created by Sergey Korobin on 15.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit
import TextFieldEffects

class DataInputTableViewCell: UITableViewCell {

    @IBOutlet weak var loginTextField: IsaoTextField!
    
    @IBOutlet weak var passTextField: IsaoTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("INTENSE LOGIN PROCESS")
    }
    
    @IBAction func moveToRegistrationTapped(_ sender: UIButton) {
        print("move to registration page")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
