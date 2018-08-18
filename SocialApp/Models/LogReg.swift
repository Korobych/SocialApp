//
//  LogReg.swift
//  SocialApp
//
//  Created by Sergey Korobin on 03.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
// *** INVALID ***

struct InvReg: Codable {
    var id: String // INT
    var name: String
    var number: String
    var password: String
    
    init(id: String, name: String, number: String, password: String ) {
        self.id = id
        self.name = name
        self.number = number
        self.password = password
    }
}

struct InvLog: Codable {
    var id: String // INT
    var password: String
    
    init(id: String, password: String ) {
        self.id = id
        self.password = password
    }
}
// *** VOLUNTEER ***

struct VolReg: Codable {
    var name: String
    var number: String
    var password: String
    
    init(name: String, number: String, password: String ) {
        self.name = name
        self.number = number
        self.password = password
    }
}

struct VolLog: Codable {
    var number: String 
    var password: String
    
    init(number: String, password: String ) {
        self.number = number
        self.password = password
    }
}

/// Special for response from server decoding
struct ServResponse: Codable{
    let resp : String
}



