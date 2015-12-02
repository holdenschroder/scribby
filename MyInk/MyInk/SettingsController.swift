//
//  SettingsController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-02.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit

class SettingsController: UIViewController {
    

    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        readWriteVersion()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBarHidden = false


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
    

    @IBAction func HandleResetOnboarding(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
        let alert = UIAlertController(title: "Onboarding Reset", message: "Next time you open the app, you will experience the intro pages as if you were a new user.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

