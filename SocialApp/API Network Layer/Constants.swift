//
//  Constants.swift
//  SocialApp
//
//  Created by Sergey Korobin on 17.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation

struct APIRefference {
    struct ProductionServer {
        static let baseURL = "http://localhost:3005"
    }
    
    struct APIParameterKey {
        static let id = "id"
        static let name = "name"
        static let number = "number"
        static let password = "password"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
