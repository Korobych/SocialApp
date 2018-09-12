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
    static func volLogin(phone: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.volLogin(phone: phone, password: password))
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
    
    static func volRegistrate(name: String, phone: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.volRegistrate(name: name, phone: phone, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func invRegistrate(id: String, name: String, phone: String, password: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.invRegistrate(id: id, name: name, phone: phone, password: password))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func volExit(phone: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.volExit(phone: phone))
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    completion(value as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func invExit(id: String, completion: @escaping (NSDictionary?, Error?) -> ()) {
        Alamofire.request(APIRouter.invExit(id: id))
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
