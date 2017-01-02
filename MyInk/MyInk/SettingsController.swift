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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func readWriteVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        }
    }
    
    func deleteAllData(_ entity: String)
    {
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.coreData.managedObjectContext!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        var result: [AnyObject]?
        do {
            result = try managedContext.fetch(fetchRequest)
            for managedObject in result!
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
            let alert = UIAlertController(title: "Reset", message: "Starting from scratch!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
            result = nil
            let alert = UIAlertController(title: "Error", message: "Unable to clear your data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        catch {}
    }
    

    @IBAction func HandleResetOnboarding(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
        let alert = UIAlertController(title: "Onboarding Reset", message: "Next time you open the app, you will experience the intro pages as if you were a new user.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func HandleResetAtlas(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Reset?", message: "Are you sure that you want to reset this? Your font will be reset to the default.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Reset Cancelled")
        }
        alert.addAction(cancelAction)
        let ResetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
            self.deleteAllData("FontAtlasData")
        }
        alert.addAction(ResetAction)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.present(alert, animated: true, completion: nil)
        })
    }
    
}

