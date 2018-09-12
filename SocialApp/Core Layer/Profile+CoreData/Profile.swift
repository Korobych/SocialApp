//
//  Profile.swift
//  SocialApp
//
//  Created by Sergey Korobin on 26.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import UIKit

class Profile{
    
    var invId: String
    var name: String
    var phone: String
    var password: String
    var photo: UIImage
    
    // Inv initializer
    init(invId: String, name: String, phone: String, password: String, photo: UIImage?) {
        self.invId = invId
        self.name = name
        self.phone = phone
        self.password = password
        self.photo = photo ?? #imageLiteral(resourceName: "placeholderUser_pic")
    }
    
    // Vol initializer
    init(volName: String, phone: String, password: String, photo: UIImage?) {
        self.invId = ""
        self.name = volName
        self.phone = phone
        self.password = password
        self.photo = photo ?? #imageLiteral(resourceName: "placeholderUser_pic")
    }
}
