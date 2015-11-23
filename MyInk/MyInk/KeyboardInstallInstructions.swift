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
    
    
    @IBOutlet weak var installBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        installBtn!.layer.cornerRadius = 3.0
        installBtn!.layer.borderWidth = 1.0
        installBtn!.layer.borderColor = UIColor.redColor().CGColor
        installBtn!.layer.masksToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedKeyboardInstructions)
    }
    
    

}