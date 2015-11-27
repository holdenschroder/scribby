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
        
        UINavigationBar.appearance().barTintColor = SharedMyInkValues.MyInkDarkColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        self.coreData.saveContext()
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

