//
//  KeyboardInstallInstructions.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-17.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import QuartzCore   

class KeyboardInstallationInstructions:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedKeyboardInstructions)
    }
    
    

}