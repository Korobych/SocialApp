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
    
    static func deleteAppUser(in context: NSManagedObjectContext) -> Bool {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assertionFailure("Model is not available in context")
            return false
        }
        guard let fetchRequest = AppUser.fetchRequestAppUser(withModel: model) else {
            return false
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            // There we get rid of App User row
            if let foundUser = results.first {
                
                // FIXIT
                // *****
                // add logic with detecting founduser.currentUser and deleting it
                // *****
                let userDeleted = User.deleteCurrentAppUser(in: context)
                foundUser.currentUser = nil
                context.delete(foundUser)
                
                if userDeleted{
                    return true
                } else {
                    print("User entity can't be or already deleted!")
                    return false
                }
                
            } else {
                print("There isn't any AppUser in context!")
                return false
            }
            
        } catch {
            print("Failed to delete AppUser: \(error.localizedDescription)")
            return false
        }
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
    
    static func deleteCurrentAppUser(in context: NSManagedObjectContext) -> Bool{
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let result = try context.fetch(fetchRequest)
            // FIXIT
            //*****************************************
            // add logic with checking what user we are deleting?
            // because now we are deleting all if them!
            //*****************************************
            for user in result {
                context.delete(user)
            }
            return true
        } catch {
            print("Failed to delete current user: \(error)")
            return false
        }
    }
}



