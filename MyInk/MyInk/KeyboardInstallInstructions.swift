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
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedKeyboardInstructions)
    }
    
    @IBAction func openPhraseCapture(sender:AnyObject) {
        let tutorialState = (UIApplication.sharedApplication().delegate as! AppDelegate).tutorialState
        tutorialState?.wordIndex = 0
        MyInkAnalytics.StartTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: ["Resuming":String(Int(tutorialState!.wordIndex) > 0)])
        presentViewController(UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewControllerWithIdentifier("TutorialIntro") as UIViewController, animated: true, completion: nil)
    }
    
    

}