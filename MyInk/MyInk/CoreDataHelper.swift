//
//  CoreDataHelper.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-05.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import CoreData

class CoreDataHelper {
    static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()
    
    static var appGroupSharedDirectory:URL = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedMyInkValues.AppGroup) ?? URL(string: "")!
    }()
    
    static var saveDirectory:URL = {
        return appGroupSharedDirectory
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MyInk", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    
    func managedObjectModelForVersion(_ version:String) -> NSManagedObjectModel {
    func managedObjectModelForVersion(_ version: String) -> NSManagedObjectModel {
        let modelURL = Bundle.main.url(forResource: "MyInk.momd/MyInk \(version)", withExtension: "mom")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = CoreDataHelper.saveDirectory.appendingPathComponent("MyInk.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options:[String:Bool] = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // - Embedded Core Data Support
    
    lazy var embededStoreCoordinator: NSPersistentStoreCoordinator? = {
        //The embedded version of the Font Data is not always loading the newest version, so we declare which version we are going to use
        let objectModel = self.managedObjectModelForVersion(SharedMyInkValues.EmbeddedFontDataVersion)
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let url = Bundle.main.url(forResource: "Embedded_data", withExtension: "sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options:[String:Bool] = [NSInferMappingModelAutomaticallyOption: true, NSReadOnlyPersistentStoreOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var embeddedManagedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.embededStoreCoordinator
        if coordinator == nil {
            return nil
        }
        let objectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        objectContext.persistentStoreCoordinator = coordinator
        return objectContext
        }()
    
    // - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}
