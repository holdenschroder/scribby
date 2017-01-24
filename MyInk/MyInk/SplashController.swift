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
    var audioHelper = AudioHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        //defaults.setBool(false, forKey: SharedMyInkValues.kDefaultsUserHasBoarded) // DEBUG ONLY
        shouldShowOnboarding = true
        if(defaults.bool(forKey: SharedMyInkValues.kDefaultsUserHasBoarded) ) {
            shouldShowOnboarding = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.audioHelper.playWelcomeSound()
            self.logo.alpha = 1.0
        })
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(2.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.navigate()
        })
    }
    
    func navigate() {
        if(shouldShowOnboarding == true) {
            performSegue(withIdentifier: "segueSplashToWelcome", sender: self)
        }
        else {
            present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationRoot") as UIViewController, animated: true, completion: nil)
        }
    }

}
