//
//  WelcomeController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-25.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit

class WelcomeController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textfield: UITextField?
    @IBOutlet weak var mButton: UIButton!
    var audioHelper = AudioHelper()
    
    private var _fontMessageRenderer:FontMessageRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textfield!.delegate = self
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textfield?.text = ""
        mButton.enabled = false
        mButton.hidden = true
        self.mButton!.layer.removeAllAnimations()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.0, animations: {
            self.textfield?.becomeFirstResponder()
        })
        UIView.animateWithDuration(2.0, animations: {
            self.mButton.alpha = 1.0
            self.mButton.hidden = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ExampleController {
            let vc = segue.destinationViewController as! ExampleController
            //let message = textfield?.text
            
            if(textfield?.text!.characters.count > 0) {
                var message = ""
                if(textfield?.text!.characters.count < 30) {
                    message += "          "
                    message += (textfield?.text!)!
                    message += "          "
                }
                else {
                    message = (textfield?.text)!
                }
                if(_fontMessageRenderer != nil) {
                    let calculatedLineHeight = 18.0 * SharedMyInkValues.FontPointSizeToPixelRatio
                    let imageMessage = _fontMessageRenderer!.renderMessage(message, imageSize: CGSize(width: 1024, height: 4096), lineHeight:calculatedLineHeight, backgroundColor: UIColor.clearColor())
                    if imageMessage != nil {
                        vc.loadImage(imageMessage!)
                    }
                }
            }
            
//            if(message != nil && (message)!.characters.count > 0 && _fontMessageRenderer != nil) {
//                let calculatedLineHeight = 18.0 * SharedMyInkValues.FontPointSizeToPixelRatio
//                let imageMessage = _fontMessageRenderer!.renderMessage(message!, imageSize: CGSize(width: 1024, height: 4096), lineHeight:calculatedLineHeight, backgroundColor: UIColor.clearColor())
//                if imageMessage != nil {
//                    vc.loadImage(imageMessage!)
//                }
//            }
        }
    }

    func pulseButton() {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.66;
        pulseAnimation.toValue = NSNumber(float: 1.03);
        pulseAnimation.fromValue = NSNumber(float: 0.97)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        self.mButton!.layer.addAnimation(pulseAnimation, forKey: nil)
    }
    
    
    // MARK: - Delegate Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let empty = (textfield?.text == "")
        if(!empty) {
            mButton?.enabled = true
            pulseButton()
        }
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let empty = (textfield?.text == "")
        if(!empty) {
            mButton?.enabled = true
            pulseButton()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func HandleInkButton(sender: AnyObject) {
        if(textfield?.text?.characters.count > 0) {
            audioHelper.playClickSound()
            performSegueWithIdentifier("segueWelcomeToExample", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Wait!", message: "Please type a message", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
 

}
