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
    var latitude: Double
    var longitude: Double
    
    init(id: String, name: String, latitude: Double, longitude: Double, phone: String)  {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
    }
}
// *** VOLUNTEER ***

struct VolUserModel {
    var name: String
    var phone: String
    var latitude: Double
    var longitude: Double
    var status: Int
    
    init(name: String, phone: String, latitude: Double, longitude: Double, status: Int) {
        self.name = name
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
    }
}



