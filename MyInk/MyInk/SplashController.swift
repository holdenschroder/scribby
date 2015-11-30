//
//  SplashController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-25.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class SplashController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    var shouldShowOnboarding : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setBool(false, forKey: SharedMyInkValues.kDefaultsUserHasBoarded) // DEBUG ONLY
        shouldShowOnboarding = true
        if(defaults.boolForKey(SharedMyInkValues.kDefaultsUserHasBoarded) ) {
            shouldShowOnboarding = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.5, animations: {
            self.logo.alpha = 1.0
        })
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.navigate()
        })
    }
    
    func navigate() {
        if(shouldShowOnboarding == true) {
            performSegueWithIdentifier("segueSplashToWelcome", sender: self)
        }
        else {
            presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainMenu") as UIViewController, animated: true, completion: nil)
        }
    }

}
