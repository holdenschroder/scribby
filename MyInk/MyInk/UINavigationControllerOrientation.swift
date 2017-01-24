//
//  UINavigationControllerOrientation.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-21.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class UINavigationControllerOrientation: UINavigationController, UINavigationControllerDelegate {
    
    fileprivate var currentViewController:UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        currentViewController = viewController
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return supportedInterfaceOrientations
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return preferredInterfaceOrientationForPresentation
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if currentViewController != nil {
            return currentViewController!.supportedInterfaceOrientations
        }
        else
        {
            return UIInterfaceOrientationMask.all
        }
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if currentViewController != nil {
            return currentViewController!.preferredInterfaceOrientationForPresentation
        }
        else
        {
            return UIInterfaceOrientation.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
}
