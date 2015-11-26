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
    
    @IBOutlet var mTextField: UITextField?
    @IBOutlet weak var mButton: UIButton!
    
    private var _fontMessageRenderer:FontMessageRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mTextField!.delegate = self
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.5, animations: {
            self.mButton.alpha = 1.0
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ExampleController {
            let vc = segue.destinationViewController as! ExampleController
            let message = "Cop This Shit" //mTextField?.text
            if(/*message != nil && */(message).characters.count > 0 && _fontMessageRenderer != nil) {
                let calculatedLineHeight = 18.0 * SharedMyInkValues.FontPointSizeToPixelRatio
                let imageMessage = _fontMessageRenderer!.renderMessage(message, imageSize: CGSize(width: 1024, height: 4096), lineHeight:calculatedLineHeight, backgroundColor: UIColor.whiteColor())
                if imageMessage != nil {
                    vc.loadImage(imageMessage!)
                }
            }
        }
    }

    
    // MARK: - Delegate Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        mTextField!.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldDidEndOnExit(sender: UITextField) {
        mTextField!.resignFirstResponder()
        sender.resignFirstResponder()
    }

    
    @IBAction func HandleInkButton(sender: AnyObject) {
        performSegueWithIdentifier("segueWelcomeToExample", sender: self)
    }
 

}
