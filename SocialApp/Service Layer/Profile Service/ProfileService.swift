//
//  ProfileService.swift
//  SocialApp
//
//  Created by Sergey Korobin on 11.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation

protocol ProfileServiceProtocol {
    func getProfile(completion: @escaping (Profile) -> ())
    func saveProfile(_ profile: Profile, completion: @escaping (_ success: Bool) -> ())
    func deleteProfile(completion: @escaping (_ success: Bool) -> ())
}

class ProfileService: ProfileServiceProtocol {
    
    var dataManager: StorageDataManagerProtocol?
    let coreDataStack = CoreDataStack()
    
    func getProfile(completion: @escaping (Profile) -> ()) {
        dataManager = StorageManager(withStack: coreDataStack)
        dataManager?.read(completion: completion)
    }
    
    func saveProfile(_ profile: Profile, completion: @escaping (_ success: Bool) -> ()) {
        dataManager = StorageManager(withStack: coreDataStack)
        dataManager?.write(profile: profile, completion: completion)
    }
    
    func deleteProfile(completion: @escaping (_ success: Bool) -> ()){
        dataManager = StorageManager(withStack: coreDataStack)
        dataManager?.delete(completion: completion)
    }
}
