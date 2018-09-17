//
//  CoreDataStack.swift
//  SocialApp
//
//  Created by Sergey Korobin on 10.09.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol: class {
    var mainContext: NSManagedObjectContext? { get }
    var saveContext: NSManagedObjectContext? { get }
    func performSave(context: NSManagedObjectContext, completionHandler: @escaping (Bool)->())
}

class CoreDataStack : CoreDataStackProtocol {
    
    private var storeURL: URL{
        get{
            let documentsDirURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirURL.appendingPathComponent("SocialApp.sqlite")
            
            return url
        }
    }
    private let managedObjectModelName = "SocialApp"
    private var _managedObjectModel: NSManagedObjectModel?
    private var managedObjectModel: NSManagedObjectModel? {
        get{
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: managedObjectModelName,   withExtension: "momd") else {
                    print("Error getting model url")
                    return nil
                }
                guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                    assert(false, "Can't create model from current url")
                    return nil
                }
                _managedObjectModel = model
            }
            return _managedObjectModel
        }
    }
    
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get{
            if _persistentStoreCoordinator == nil{
                guard let model = managedObjectModel else { return nil }
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                do {
                    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                    _persistentStoreCoordinator = coordinator
                } catch {
                    assert(false, "Error adding store to coordinator: \(error)")
                    return nil
                }
            }
            return _persistentStoreCoordinator
        }
    }
    // Master Context
    private var _masterContext: NSManagedObjectContext?
    private var masterContext: NSManagedObjectContext? {
        get{
            if _masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let persistentStoreCoordinator = persistentStoreCoordinator else {
                    print("Empty persisent store coordinator!")
                    
                    return nil
                }
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _masterContext = context
            }
            return _masterContext
        }
    }
    //Main Context
    var _mainContext: NSManagedObjectContext?
    var mainContext: NSManagedObjectContext? {
        get{
            if _mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.masterContext else {
                    print("No master context!")
                    
                    return nil
                }
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _mainContext = context
            }
            return _mainContext
        }
    }
    //Save Context
    var _saveContext: NSManagedObjectContext?
    var saveContext: NSManagedObjectContext? {
        get{
            if _saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let parentContext = self.mainContext else {
                    print("No main context!")
                    
                    return nil
                }
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _saveContext = context
            }
            return _saveContext
        }
    }
    
    func performSave(context: NSManagedObjectContext, completionHandler: @escaping (Bool)->()) {
        
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                }
                catch{
                    print("Context save error: \(error)")
                }
                
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler)
                } else {
                    completionHandler(true)
                }
            }
        } else {
            completionHandler(true)
        }
    }
}




