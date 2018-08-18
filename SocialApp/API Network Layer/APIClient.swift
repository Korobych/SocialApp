//
//  APIClient.swift
//  SocialApp
//
//  Created by Sergey Korobin on 17.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    static func volLogin(number: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.volLogin(number: number, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    static func invLogin(id: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.invLogin(id: id, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func volRegistrate(name: String, number: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.volRegistrate(name: name, number: number, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func invRegistrate(id: String, name: String, number: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.invRegistrate(id: id, name: name, number: number, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    
    
}

