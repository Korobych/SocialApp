//
//  APIRouter.swift
//  SocialApp
//
//  Created by Sergey Korobin on 17.08.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: APIConfiguration {
    
    case volLogin(phone: String, password: String)
    case invLogin(id: String, password: String)
    case volRegistrate(name: String, phone: String, password: String)
    case invRegistrate(id: String, name: String, phone: String, password: String)
    case volExit(phone: String)
    case invExit(id: String)
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        // should be with switch (add if needed)
        //        switch self {
        //        case .login:
        //            return .post
        //        case .profile:
        //            return .get
        //        }
        return .post
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .volLogin:
            return "/vol/in"
        case .invLogin:
            return "/inv/in"
        case .volRegistrate:
            return "/vol/up"
        case .invRegistrate:
            return "/inv/up"
        case .volExit:
            return "/vol/ex"
        case .invExit:
            return "/inv/ex"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .volLogin(let phone, let password):
            return [APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.password : password]
        case .invLogin(let id, let password):
            return [APIRefference.APIParameterKey.id : id, APIRefference.APIParameterKey.password : password]
        case .volRegistrate(let name, let phone, let password):
            return [APIRefference.APIParameterKey.name : name, APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.password : password]
        case .invRegistrate(let id, let name, let phone, let password):
            return [APIRefference.APIParameterKey.id : id, APIRefference.APIParameterKey.name : name, APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.password : password]
        case .volExit(let phone):
            return [APIRefference.APIParameterKey.phone : phone]
        case .invExit(let id):
            return [APIRefference.APIParameterKey.id : id]
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try APIRefference.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
