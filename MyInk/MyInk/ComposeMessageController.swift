//
//  ComposeMessageController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import QuartzCore

class ComposeMessageController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView:UITextView?
    @IBOutlet var generateButton:UIButton?
    @IBOutlet weak var pointSizeStepper: UIStepper!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var propertiesBar: UIView!
    
    private let _pointSizeOptions:[Float] = [10, 12, 14, 16, 18, 20, 24, 28, 32]
    private var _fontMessageRenderer:FontMessageRenderer?
    private var _selectedPointSize = 3
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        textView?.delegate = self

        if isMovingToParentViewController() {
            textView?.text = ""
        }
        if textView != nil {
            generateButton?.enabled = textView!.hasText()
            textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
        }
        
        propertiesBar.layer.cornerRadius = 3.0
        
        fontSizeLabel.layer.cornerRadius = 6.0
        fontSizeLabel.layer.borderWidth = 1.0
        fontSizeLabel.layer.borderColor = UIColor.blackColor().CGColor
        fontSizeLabel.layer.masksToBounds = true
        fontSizeLabel.text = "10"
        
        pointSizeStepper.autorepeat = false
        pointSizeStepper.minimumValue = 0.0
        pointSizeStepper.maximumValue = 8.0

        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
        
        registerForKeyboardNotifications()
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedComposeMessage)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ShareImageController {
            let shareImageController = segue.destinationViewController as! ShareImageController
            
            let message = textView?.text
            if(message != nil && (message!).characters.count > 0 && _fontMessageRenderer != nil) {
                let calculatedLineHeight = CGFloat(_pointSizeOptions[_selectedPointSize]) * SharedMyInkValues.FontPointSizeToPixelRatio
                
                let imageMessage = _fontMessageRenderer!.renderMessage(message!, imageSize: CGSize(width: 1024, height: 4096), lineHeight:calculatedLineHeight, backgroundColor: UIColor.whiteColor())
                if imageMessage != nil {
                    shareImageController.loadImage(imageMessage!)
                }
                //navigationController?.showViewController(shareImageController, sender: self)
            }
        }
    }
    
    //-- Stepper
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        fontSizeLabel.text = String(Int(_pointSizeOptions[Int(sender.value)]))
        textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[Int(sender.value)]))
    }
    
    //-- UITextViewDelegate Methods
    
    func textViewDidChange(textView: UITextView) {
        generateButton?.enabled = !textView.text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //-- Keyboard Methods
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleKeyboardDidShow(notification:NSNotification) {
        let info = notification.userInfo as? [String:AnyObject]
        if info != nil && textView != nil {
            let kbRect = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            bottomConstraint.constant = kbRect.height + 20
            textView?.layoutIfNeeded()
            textView!.scrollRangeToVisible(textView!.selectedRange)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.generateButton?.frame.origin.y -= kbRect.height
            }
        }
    }
    
    func handleKeyboardDidHide(notification:NSNotification) {
        bottomConstraint.constant = 0
        textView?.layoutIfNeeded()
    }
}