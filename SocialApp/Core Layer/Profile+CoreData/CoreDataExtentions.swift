//
//  CoreDataExtentions.swift
//  SocialApp
//
//  Created by Sergey Korobin on 10.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

//*************************//
// AppUser Entity extension
//*************************//
extension AppUser {
    
    static func findAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assertionFailure("Model is not available in context")
            return nil
        }
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(withModel: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error.localizedDescription)")
        }
        
        return appUser
    }
    
    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assertionFailure("Model is not available in context")
            return nil
        }
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(withModel: model) else {
            return nil
        }
        
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error.localizedDescription)")
        }
        
        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        
        
        return appUser
    }
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.insertAppUser(in: context)
                appUser.currentUser = currentUser
            } else {
                print("AppUser is already created. Looks like you forget to delete it.")
            }
            return appUser
        }
        
        return nil
    }
    
    static func fetchRequestAppUser(withModel model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assertionFailure("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest
    }
    
}

//*************************//
// User Entity extension
//*************************//
extension User {
    
    static func insertAppUser(in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            return user
        }
        return nil
    }
}



