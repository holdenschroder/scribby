//
//  ComposeMessageController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import QuartzCore

let composeMessageTextViewPlaceholder = "Type your message here"

class ComposeMessageController: UIViewController, UITextViewDelegate {
    
    // MARK: - VARS
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var generateButton: UIButton?
    @IBOutlet weak var pointSizeStepper: UIStepper!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var propertiesBar: UIView!
    
    private let _pointSizeOptions: [Float] = [18, 24, 36]
    private let _pointSizeStrings: [String] = ["Small", "Medium", "Large"]
    private var _fontMessageRenderer: FontMessageRenderer?
    private var _selectedPointSize = 1
    var audioHelper = AudioHelper()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        textView.delegate = self
        setUpPlaceholderAndButton()

        propertiesBar.layer.cornerRadius = 3.0
        pointSizeStepper.autorepeat = false
        pointSizeStepper.minimumValue = 0.0
        pointSizeStepper.maximumValue = 2.0
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedComposeMessage)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        registerForKeyboardNotifications()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        setUpPlaceholderAndButton()
        textView.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
        fontSizeLabel.text = String(_pointSizeStrings[_selectedPointSize])
        UIView.animateWithDuration(0.25, animations: {
            self.textView.becomeFirstResponder()
        })
    }

    private func setUpPlaceholderAndButton() {
        if (textView.text.characters.count == 0) {
            textView.text = composeMessageTextViewPlaceholder
            textView.textColor = UIColor.lightGrayColor()
            generateButton?.enabled = false
            self.generateButton!.layer.removeAllAnimations()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        UIView.animateWithDuration(0.25, animations: {
            self.textView.resignFirstResponder()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ShareImageController {
            let shareImageController = segue.destinationViewController as! ShareImageController
            if(textView.text.characters.count > 0) {
                var message = ""
                if(textView.text.characters.count < 30) {
//                    message += "          "
                    message += textView.text
//                    message += "          "
                }
                else {
                    message = (textView.text)!
                }
                if(_fontMessageRenderer != nil) {
                    let calculatedLineHeight = CGFloat(_pointSizeOptions[_selectedPointSize]) * SharedMyInkValues.FontPointSizeToPixelRatio
                    let imageMessage = _fontMessageRenderer!.renderMessage(message, imageSize: CGSize(width: 1024, height: 4096 * 16), lineHeight: calculatedLineHeight, backgroundColor: beigeMessageBackgroundColor, showDebugInfo: false, enforceAspectRatio: true)
                    if imageMessage != nil {
                        shareImageController.loadImage(imageMessage!)
                    }
                }
            }
        }
    }
    
    // MARK: - ACTIONS
    
    
    @IBAction func HandleInkAction(sender: AnyObject) {
        if (textView.text.characters.count > 0) {
            audioHelper.playClickSound()
            performSegueWithIdentifier("composeToShare", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Wait!", message: "Please type a message", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
        self.generateButton!.layer.addAnimation(pulseAnimation, forKey: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        if (textView.text != composeMessageTextViewPlaceholder) {
            pulseButton()
        }
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        _selectedPointSize = Int(sender.value)
        fontSizeLabel.text = String(_pointSizeStrings[_selectedPointSize])
        textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[Int(sender.value)]))
    }
    
    // MARK: - TEXTVIEW DELEGATE
    
    func textViewDidChange(textView: UITextView) {
        generateButton?.enabled = !textView.text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (textView.text == composeMessageTextViewPlaceholder) {
            textView.text = ""
            textView.textColor = SharedMyInkValues.MyInkLightColor
        }
        return true
    }

    
    // MARK: - KEYBOARD

    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeMessageController.handleKeyboardDidShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeMessageController.handleKeyboardDidHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo as? [String:AnyObject]
        if info != nil && textView != nil {
            let kbRect = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            bottomConstraint.constant = kbRect.height + 20
            textView!.scrollRangeToVisible(textView!.selectedRange)
        }
        animateConstraintChanges()
    }

    func handleKeyboardDidHide(notification: NSNotification) {
        bottomConstraint.constant = 20
        animateConstraintChanges()
    }

    private func animateConstraintChanges() {
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
