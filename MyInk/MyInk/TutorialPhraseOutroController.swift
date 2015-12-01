//
//  TutorialPhraseOutro.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-05.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TutorialPhaseOutroController: UIViewController {
    @IBOutlet weak var messageImageView:UIImageView!
    private var messageImage:UIImage?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false

        messageImageView?.image = messageImage
        
        MyInkAnalytics.EndTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: nil)
    }
    
    func setMessage(image:UIImage) {
        if messageImageView != nil {
            messageImageView?.image = image
        }
        messageImage = image
    }
    
    @IBAction func HandleOkBtn(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
        presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationRoot") as UIViewController, animated: true, completion: nil)
    }
    
    
}