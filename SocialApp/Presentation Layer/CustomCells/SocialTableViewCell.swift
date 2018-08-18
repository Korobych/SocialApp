//
//  SocialTableViewCell.swift
//  SocialApp
//
//  Created by Sergey Korobin on 15.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit

class SocialTableViewCell: UITableViewCell {

    @IBOutlet weak var firstButton: UIButton!
    
    @IBOutlet weak var secondButton: UIButton!
    
    @IBOutlet weak var thirdButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        // handle login with this service here
        print("Login with Twitter!")
    }
    
    @IBAction func secondButtonTapped(_ sender: UIButton) {
        // handle login with this service here
        print("Login with VK!")
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        // handle login with this service here
        print("Login with Odnoklassniki!")
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
