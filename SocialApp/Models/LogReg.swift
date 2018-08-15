//
//  LogReg.swift
//  SocialApp
//
//  Created by Sergey Korobin on 03.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
// *** INVALID ***

struct InvReg {
    var id: String // INT
    var name: String
    var number: String // INT
    var password: String
    
    init(id: String, name: String, number: String, password: String ) {
        self.id = id
        self.name = name
        self.number = number
        self.password = password
    }
}

struct InvLog {
    var number: String // INT
    var password: String
    
    init(number: String, password: String ) {
        self.number = number
        self.password = password
    }
}
// *** VOLUNTEER ***

struct VolReg {
    var name: String
    var number: String // INT
    var password: String
    
    init(name: String, number: String, password: String ) {
        self.name = name
        self.number = number
        self.password = password
    }
}

struct VolLog {
    var number: String // INT
    var password: String
    
    init(number: String, password: String ) {
        self.number = number
        self.password = password
    }
}



