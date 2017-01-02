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
    fileprivate var messageImage:UIImage?
    
    var audioHelper = AudioHelper()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        messageImageView?.image = messageImage
        MyInkAnalytics.EndTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: nil)
    }
    
    func setMessage(_ image:UIImage) {
        if messageImageView != nil {
            messageImageView?.image = image
        }
        messageImage = image
    }
    
    @IBAction func HandleOkBtn(_ sender: AnyObject) {
        audioHelper.playClickSound()
        UserDefaults.standard.set(true, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
        present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationRoot") as UIViewController, animated: true, completion: nil)
    }
    
    
}
