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
        static let baseURL = "http://142.93.71.221:3000"
    }
    
    struct APIParameterKey {
        static let id = "id"
        static let name = "name"
        static let phone = "phone"
        static let password = "password"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let conid = "conid"
        static let review = "review"
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
