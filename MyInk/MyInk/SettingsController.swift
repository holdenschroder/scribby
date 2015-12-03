//
//  SettingsController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-02.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit
import CoreData


class SettingsController: UIViewController {
    

    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readWriteVersion()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func readWriteVersion() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                let info = "Version: \(version) Build: (\(build))"
                print(info)
                versionLabel.text = info
            }
        }
    }
    
    func deleteAllData(entity: String)
    {
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.coreData.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        var result: [AnyObject]?
        do {
            result = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in result!
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
            let alert = UIAlertController(title: "Reset", message: "Starting from scratch!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
            result = nil
            let alert = UIAlertController(title: "Error", message: "Unable to clear your data.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        catch {}
    }
    

    @IBAction func HandleResetOnboarding(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
        let alert = UIAlertController(title: "Onboarding Reset", message: "Next time you open the app, you will experience the intro pages as if you were a new user.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func HandleResetAtlas(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset?", message: "Are you sure that you want to reset this? Your font will be reset to the default.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Reset Cancelled")
        }
        alert.addAction(cancelAction)
        let ResetAction = UIAlertAction(title: "Reset", style: .Default) { (action) in
            self.deleteAllData("FontAtlasData")
        }
        alert.addAction(ResetAction)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
}

