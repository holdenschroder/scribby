//
//  PromptForRotationController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-04.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class PromptForRotationController: UIViewController {
    private var _delayTimer:NSTimer?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.currentDevice().orientation.isLandscape  {
            _delayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PromptForRotationController.showTutorialScreen(_:)), userInfo: nil, repeats: false)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if UIDevice.currentDevice().orientation.isLandscape  {
            _delayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PromptForRotationController.showTutorialScreen(_:)), userInfo: nil, repeats: false)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func showTutorialScreen(timer:NSTimer) {
        let tutorialController = storyboard?.instantiateViewControllerWithIdentifier("TutorialPhrase") as? TutorialPhraseController
        
        if tutorialController != nil {
            presentViewController(tutorialController!, animated: true, completion: nil)
        }
    }
}
