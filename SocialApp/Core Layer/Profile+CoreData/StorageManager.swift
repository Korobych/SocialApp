//
//  StorageManager.swift
//  SocialApp
//
//  Created by Sergey Korobin on 11.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import UIKit

protocol StorageDataManagerProtocol {
    func write(profile: Profile, completion: @escaping (_ success: Bool) -> ())
    func read(completion: @escaping (_ profile: Profile) -> Void)
    func delete(completion: @escaping (_ success: Bool) -> ())
}

class StorageManager: StorageDataManagerProtocol  {
    
    
    let dataStack: CoreDataStackProtocol
    init(withStack dataStack: CoreDataStackProtocol) {
        self.dataStack = dataStack
    }
    
    func write(profile: Profile, completion: @escaping (_ success: Bool) -> ()){
        
        guard let appUser = AppUser.findOrInsertAppUser(in: dataStack.saveContext!) else {
            completion(false)
            return
        }
        guard let user = appUser.currentUser else {
            completion(false)
            return
        }
        
        let photoRepresentation = UIImagePNGRepresentation(profile.photo)
        
        user.inv_id = profile.invId
        user.name = profile.name
        user.phone = profile.phone
        user.password = profile.password
        user.photo = photoRepresentation
        
        dataStack.saveContext?.perform {
            self.dataStack.performSave(context: self.dataStack.saveContext!) {(success) in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    func read(completion: @escaping (_ profile: Profile) -> ()) {
        dataStack.saveContext?.perform {
            guard let appUser = AppUser.findAppUser(in: self.dataStack.saveContext!)
                else {
                    print("Completion error. Clean start. There isn't profile stored!")
                    return
            }
            guard let user = appUser.currentUser else {
                print("can't find current app User")
                return
            }
            
            var customPhoto: UIImage?
            var profile: Profile
            if let photo = user.photo {
                customPhoto = UIImage(data: photo as Data)!
            }
            
            if user.inv_id == ""{
                profile = Profile(volName: user.name ?? "username", phone: user.phone ?? "yoPhoneNumber", password: user.password ?? "", photo: customPhoto)
            } else {
                profile = Profile(invId: user.inv_id ?? "userID", name: user.name ?? "username", phone: user.phone ?? "yoPhoneNumber", password: user.password ?? "", photo: customPhoto)
            }
      
            DispatchQueue.main.async {
                completion(profile)
            }
        }
    }
    
    func delete(completion: @escaping (Bool) -> ()) {
        guard let appUser = AppUser.findAppUser(in: self.dataStack.saveContext!)
            else {
                print("There is no App User in data storage.")
                completion(false)
                return
        }
        guard let _ = appUser.currentUser else {
            print("can't find current app User")
            completion(false)
            return
        }
        
        let deleteCompleted = AppUser.deleteAppUser(in: self.dataStack.saveContext!)
        
        dataStack.saveContext?.perform {
            self.dataStack.performSave(context: self.dataStack.saveContext!) {(success) in
                DispatchQueue.main.async {
                    completion(success && deleteCompleted)
                }
            }
        }
        
    }
    
}
