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
    
    // MARK: - VARS
    
    @IBOutlet var textView:UITextView?
    @IBOutlet var generateButton:UIButton?
    @IBOutlet weak var pointSizeStepper: UIStepper!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var propertiesBar: UIView!
    @IBOutlet weak var mActivityIndicator: UIActivityIndicatorView!
    
    private let _pointSizeOptions:[Float] = [18, 24, 36]
    private let _pointSizeStrings:[String] = ["Small", "Medium", "Large"]
    private var _fontMessageRenderer:FontMessageRenderer?
    private var _selectedPointSize = 0
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView?.delegate = self
        textView?.text = "Type your message here"
        textView?.textColor = UIColor.lightGrayColor()
        
        propertiesBar.layer.cornerRadius = 3.0
        pointSizeStepper.autorepeat = false
        pointSizeStepper.minimumValue = 0.0
        pointSizeStepper.maximumValue = 2.0
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
        
        registerForKeyboardNotifications()
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedComposeMessage)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        mActivityIndicator.hidden = true
        if isMovingToParentViewController() {
            //textView?.text = ""
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if textView != nil {
            generateButton?.enabled = textView!.hasText()
            textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
            fontSizeLabel.text = String(_pointSizeStrings[_selectedPointSize])
            UIView.animateWithDuration(0.5, animations: {
                self.textView?.becomeFirstResponder()
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        UIView.animateWithDuration(0.5, animations: {
            self.textView?.resignFirstResponder()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ShareImageController {
            let shareImageController = segue.destinationViewController as! ShareImageController
            if(textView?.text.characters.count > 0) {
                var message = ""
                if(textView?.text.characters.count < 30) {
                    message += "          "
                    message += (textView?.text!)!
                    message += "          "
                }
                else {
                    message = (textView?.text)!
                }
                print(message)
                if(_fontMessageRenderer != nil) {
                    let calculatedLineHeight = CGFloat(_pointSizeOptions[_selectedPointSize]) * SharedMyInkValues.FontPointSizeToPixelRatio
                    let imageMessage = _fontMessageRenderer!.renderMessage(message, imageSize: CGSize(width: 1024, height: 4096), lineHeight:calculatedLineHeight, backgroundColor: UIColor.whiteColor())
                    if imageMessage != nil {
                        shareImageController.loadImage(imageMessage!)
                    }
                    if(mActivityIndicator.isAnimating()) {
                        mActivityIndicator.startAnimating()
                    }
                }
            }

        }
    }
    
    // MARK: - ACTIONS
    
    
    @IBAction func HandleInkAction(sender: AnyObject) {
        if(textView?.text?.characters.count > 0) {
            mActivityIndicator.hidden = false
            mActivityIndicator.startAnimating()
            performSegueWithIdentifier("composeToShare", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Wait!", message: "Please type a message", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        fontSizeLabel.text = String(_pointSizeStrings[Int(sender.value)])
        textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[Int(sender.value)]))
    }
    
    // MARK: - TEXTVIEW DELEGATE
    
    func textViewDidChange(textView: UITextView) {
        generateButton?.enabled = !textView.text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //textView.textColor = SharedMyInkValues.MyInkLightColor
        if(textView.text == "Type your message here") {
            textView.text = ""
            textView.textColor = SharedMyInkValues.MyInkLightColor
        }
        return true
    }

    
    // MARK: - KEYBOARD

    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleKeyboardDidShow(notification:NSNotification) {
        let info = notification.userInfo as? [String:AnyObject]
        if(textView?.text == "Type your message here") {
            //textView?.text = ""
        }
        if info != nil && textView != nil {
            let kbRect = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            bottomConstraint.constant = kbRect.height + 20
            textView?.layoutIfNeeded()
            textView!.scrollRangeToVisible(textView!.selectedRange)
        }
    }
    
    func handleKeyboardDidHide(notification:NSNotification) {
        bottomConstraint.constant = 0
        textView?.layoutIfNeeded()
    }
}