//
//  TutorialPhraseOutro.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-05.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TutorialPhaseOutroController: TapToContinueController {
    @IBOutlet weak var messageImageView:UIImageView!
    private var messageImage:UIImage?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        messageImageView?.image = messageImage
        
        MyInkAnalytics.EndTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: nil)
    }
    
    func setMessage(image:UIImage) {
        if messageImageView != nil {
            messageImageView?.image = image
        }
        messageImage = image
    }
}