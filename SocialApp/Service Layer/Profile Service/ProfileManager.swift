//
//  ProfileManager.swift
//  SocialApp
//
//  Created by Sergey Korobin on 11.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileManagerProtocol {
    var delegate: ProfileManagerDelegateProtocol? {get set}
    func getProfileInfo()
    func saveInvProfile(id: String?, name: String?, phone: String?, password: String?, photo: UIImage?)
    func saveVolProfile(name: String?, phone: String?, password: String?, photo: UIImage?)
//    func profileDidChange(photo: UIImage?, name: String?, info: String?) -> Bool
}

protocol ProfileManagerDelegateProtocol: class {
    
//    do we need it or not?
//    func didGet(profileViewModel: ProfileViewModel)
    func didFinishSave(success: Bool)
}

class ProfileManager: ProfileManagerProtocol {
    
    var lastSavedProfile: Profile?
    weak var delegate: ProfileManagerDelegateProtocol?
    let profileService: ProfileServiceProtocol = ProfileService()
    
    func getProfileInfo() {
        profileService.getProfile { [weak self] profile in
//            let profileViewModel = ProfileViewModel(profile: profile)
//            self?.delegate?.didGet(profileViewModel: profileViewModel)
            self?.lastSavedProfile = profile
        }
    }
    
    func saveInvProfile(id: String?, name: String?, phone: String?, password: String?, photo: UIImage?) {
        guard let id = id, let name = name, let phone = phone, let password = password, let photo = photo else {
            self.delegate?.didFinishSave(success: false)
            return
        }
        
        let profile = Profile(invId: id, name: name, phone: phone, password: password, photo: photo)
        profileService.saveProfile(profile) { [weak self] success in
            self?.delegate?.didFinishSave(success: success)
            self?.lastSavedProfile = profile
        }
    }
    
    func saveVolProfile(name: String?, phone: String?, password: String?, photo: UIImage?) {
        guard let name = name, let phone = phone, let password = password, let photo = photo else {
            self.delegate?.didFinishSave(success: false)
            return
        }
        
        let profile = Profile(volName: name, phone: phone, password: password, photo: photo)
        profileService.saveProfile(profile) { [weak self] success in
            self?.delegate?.didFinishSave(success: success)
            self?.lastSavedProfile = profile
        }
    }
    
//    func profileDidChange(photo: UIImage?, name: String?, info: String?) -> Bool {
//        var checkingFlag: Bool = false
//        guard let lastSavedProfile = lastSavedProfile else {
//            return true
//        }
//
//        guard let photo = photo, let name = name, let info = info,
//            !name.isEmpty, !info.isEmpty else {
//                return false
//        }
//        checkingFlag = photo != lastSavedProfile.photo || name != lastSavedProfile.name || info != lastSavedProfile.info
//        return checkingFlag
//    }
}
