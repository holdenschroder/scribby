//
//  PromptForRotationController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-04.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class PromptForRotationController: UIViewController {
    fileprivate var _delayTimer:Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.orientation.isLandscape  {
            _delayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PromptForRotationController.showTutorialScreen(_:)), userInfo: nil, repeats: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape  {
            _delayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PromptForRotationController.showTutorialScreen(_:)), userInfo: nil, repeats: false)
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    func showTutorialScreen(_ timer:Timer) {
        let tutorialController = storyboard?.instantiateViewController(withIdentifier: "TutorialPhrase") as? TutorialPhraseController
        
        if tutorialController != nil {
            present(tutorialController!, animated: true, completion: nil)
        }
    }
}
