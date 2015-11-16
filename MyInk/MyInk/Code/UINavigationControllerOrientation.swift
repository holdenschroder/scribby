//
//  UINavigationControllerOrientation.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-21.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class UINavigationControllerOrientation: UINavigationController, UINavigationControllerDelegate {
    
    private var currentViewController:UIViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        currentViewController = viewController
    }
    
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return supportedInterfaceOrientations()
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation {
        return preferredInterfaceOrientationForPresentation()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if currentViewController != nil {
            return currentViewController!.supportedInterfaceOrientations()
        }
        else
        {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if currentViewController != nil {
            return currentViewController!.preferredInterfaceOrientationForPresentation()
        }
        else
        {
            return UIInterfaceOrientation.Portrait
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
