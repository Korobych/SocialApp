//
//  LogReg.swift
//  SocialApp
//
//  Created by Sergey Korobin on 03.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
// *** INVALID ***

struct InvUserModel: Codable {
    var id: String
    var name: String
    var phone: String
    var password: String
    
    init(id: String, name: String, phone: String, password: String ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.password = password
    }
}
// *** VOLUNTEER ***

struct VolUserModel: Codable {
    var name: String
    var phone: String
    var password: String
    
    init(name: String, phone: String, password: String ) {
        self.name = name
        self.phone = phone
        self.password = password
    }
}



