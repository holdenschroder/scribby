//
//  TapToContinueController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-05.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TapToContinueController: UIViewController {
    @IBInspectable var controllerIDToLoad:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TapToContinueController.handleTap(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    func handleTap(_ sender:AnyObject) {
        if controllerIDToLoad != nil && !controllerIDToLoad!.isEmpty {
            let controller = storyboard?.instantiateViewController(withIdentifier: controllerIDToLoad!)
            if controller != nil {
                self.present(controller!, animated: true, completion: nil)
            }
        }
    }
}
