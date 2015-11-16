//
//  AppDelegate.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-09.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreData:CoreDataHelper = {
        return CoreDataHelper()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self()])
        MyInkAnalytics.Initialize([FlurryWrapper(), ParseWrapper(launchOptions: launchOptions)])
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.coreData.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: - Atlas Data
    
    lazy var currentAtlas:FontAtlas? = {
        var atlas = FontAtlas(name: SharedMyInkValues.DefaultUserAtlas, atlasDirectory: SharedMyInkValues.DefaultAtlasDirectory, managedObjectContext: self.coreData.managedObjectContext!)
        atlas.onSaveEvents.append(self.handleAtlasSave)
        return atlas
    }()
    
    lazy var embeddedAtlas:FontAtlas? = {
        var atlas = FontAtlas(name: SharedMyInkValues.EmbeddedAtlasName, atlasDirectory: SharedMyInkValues.EmbeddedAtlasDirectory, managedObjectContext: self.coreData.embeddedManagedObjectContext!)
        return atlas
    }()
    
    lazy var tutorialState:TutorialState? = {
        let request = NSFetchRequest(entityName: "TutorialState")
        let results:[AnyObject]?
        do {
            results = try self.coreData.managedObjectContext!.executeFetchRequest(request)
        }
        catch let error as NSError {
            results = nil
            print("Error Initializing Tutorial State \(error.description)")
        }
        var tutorialState:TutorialState?
        if(results == nil || results?.count == 0) {
            tutorialState = NSEntityDescription.insertNewObjectForEntityForName("TutorialState", inManagedObjectContext: self.coreData.managedObjectContext!) as? TutorialState
            tutorialState?.Initialize()
        }
        else {
            tutorialState = results?.first as? TutorialState
        }
        
        return tutorialState;
    }()
    
    private func handleAtlasSave(atlas:FontAtlas) {
        self.coreData.saveContext()
    }
}

