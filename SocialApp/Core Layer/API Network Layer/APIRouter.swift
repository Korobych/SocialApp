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
    case volGeoList()
    case invGeoList()
    case volHelp(phone: String, latitude: String, longitude: String)
    case invHelp(id: String, latitude: String, longitude: String)
    case volGetInv(phone: String, conid: String)
    case invStopHelp(conid: String, phone: String, review: String)
    case updateVolGeo(phone: String, latitude: String, longitude: String)
    case updateInvGeo(id: String, latitude: String, longitude: String)
    case helperInfo(id: String)
    case helperGeo(id: String)
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .volLogin:
            return .post
        case .invLogin:
            return .post
        case .volRegistrate:
            return .post
        case .invRegistrate:
            return .post
        case .volExit:
            return .post
        case .invExit:
            return .post
        case .volGeoList:
            return .get
        case .invGeoList:
            return .get
        case .volHelp:
            return .post
        case .invHelp:
            return .post
        case .volGetInv:
            return .post
        case .invStopHelp:
            return .post
        case .updateVolGeo:
            return .post
        case .updateInvGeo:
            return .post
        case .helperInfo:
            return .post
        case .helperGeo:
            return .post
        }
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
        case .volGeoList:
            return "/vol/geolist"
        case .invGeoList:
            return "/inv/geolist"
        case .volHelp:
            return "/vol/ch"
        case .invHelp:
            return "/inv/nh"
        case .volGetInv:
            return "/vol/help"
        case .invStopHelp:
            return "/inv/stophelp"
        case .updateVolGeo:
            return "/vol/gp"
        case .updateInvGeo:
            return "/inv/gp"
        case .helperInfo:
            return "/inv/helperinfo"
        case .helperGeo:
            return "/inv/volgeo"
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
        case .volGeoList:
            return nil
        case .invGeoList:
            return nil
        case .volHelp(let phone, let latitude, let longitude):
            return [APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.latitude : latitude, APIRefference.APIParameterKey.longitude : longitude]
        case .invHelp(let id, let latitude, let longitude):
            return [APIRefference.APIParameterKey.id : id, APIRefference.APIParameterKey.latitude : latitude, APIRefference.APIParameterKey.longitude : longitude]
        case .volGetInv(let phone, let conid):
            return [APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.conid : conid]
        case .invStopHelp(let conid, let phone, let review):
            return [APIRefference.APIParameterKey.conid : conid, APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.review : review]
        case .updateVolGeo(let phone, let latitude, let longitude):
            return [APIRefference.APIParameterKey.phone : phone, APIRefference.APIParameterKey.latitude : latitude, APIRefference.APIParameterKey.longitude : longitude ]
        case .updateInvGeo(let id, let latitude, let longitude):
            return [APIRefference.APIParameterKey.id : id, APIRefference.APIParameterKey.latitude : latitude, APIRefference.APIParameterKey.longitude : longitude]
        case .helperInfo(let id):
            return [APIRefference.APIParameterKey.id : id]
        case .helperGeo(let id):
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
