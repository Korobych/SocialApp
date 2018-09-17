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
    var lastSavedProfile: Profile? {get set}
    var delegate: ProfileManagerDelegateProtocol? {get set}
    func getProfileInfo()
    func saveInvProfile(id: String?, name: String?, phone: String?, password: String?, photo: UIImage?)
    func saveVolProfile(name: String?, phone: String?, password: String?, photo: UIImage?)
    func deleteProfile()
}

protocol ProfileManagerDelegateProtocol: class {
    
    func didFinishSave(success: Bool)
    func didFinishDeleting(success: Bool)
    func didFinishReading(profile: Profile)
}

class ProfileManager: ProfileManagerProtocol {
    
    var lastSavedProfile: Profile?
    weak var delegate: ProfileManagerDelegateProtocol?
    let profileService: ProfileServiceProtocol = ProfileService()
    
    func getProfileInfo() {
        profileService.getProfile { [weak self] profile in

            self?.delegate?.didFinishReading(profile: profile)
            self?.lastSavedProfile = profile
        }
    }
    
    func saveInvProfile(id: String?, name: String?, phone: String?, password: String?, photo: UIImage?) {
        // add let photo = photo??
        guard let id = id, let name = name, let phone = phone, let password = password else {
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
        // add let photo = photo??
        guard let name = name, let phone = phone, let password = password else {
            self.delegate?.didFinishSave(success: false)
            return
        }
        
        let profile = Profile(volName: name, phone: phone, password: password, photo: photo)
        profileService.saveProfile(profile) { [weak self] success in
            self?.delegate?.didFinishSave(success: success)
            self?.lastSavedProfile = profile
        }
    }
    
    func deleteProfile() {
        profileService.deleteProfile { [weak self] success in
            self?.delegate?.didFinishDeleting(success: success)
        }
    }
}
