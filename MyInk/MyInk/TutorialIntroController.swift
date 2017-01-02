//
//  TutorialIntroController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-26.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TutorialIntroController: UIViewController {
    
    var audioHelper = AudioHelper()
    
    @IBAction func playSound(_ sender:AnyObject) {
        audioHelper.playClickSound()
    }
    
    
}
