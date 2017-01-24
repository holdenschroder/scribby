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
    
    fileprivate let _pointSizeOptions: [Float] = [24, 34, 48]
    fileprivate let _pointSizeStrings: [String] = ["Small", "Medium", "Large"]
    fileprivate var _fontMessageRenderer: FontMessageRenderer?
    fileprivate var _selectedPointSize = 1
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
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.shared.delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedComposeMessage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        registerForKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUpPlaceholderAndButton()
        textView.font = textView!.font!.withSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
        fontSizeLabel.text = String(_pointSizeStrings[_selectedPointSize])
        UIView.animate(withDuration: 0.25, animations: {
            self.textView.becomeFirstResponder()
        })
    }

    fileprivate func setUpPlaceholderAndButton() {
        if (textView.text.characters.count == 0) {
            textView.text = composeMessageTextViewPlaceholder
            textView.textColor = UIColor.lightGray
            generateButton?.isEnabled = false
            self.generateButton!.layer.removeAllAnimations()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        UIView.animate(withDuration: 0.25, animations: {
            self.textView.resignFirstResponder()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShareImageController {
            let shareImageController = segue.destination as! ShareImageController
            let message = textView.text!
            if(_fontMessageRenderer != nil) {
                let calculatedLineHeight = CGFloat(_pointSizeOptions[_selectedPointSize]) * SharedMyInkValues.FontPointSizeToPixelRatio
                if let imageMessage = _fontMessageRenderer!.render(message: message, width: 750, lineHeight: calculatedLineHeight, backgroundColor: FontMessageRenderer.beige, maxAspectRatio: 1.75) {
                    shareImageController.loadImage(imageMessage)
                }
            }
        }
    }
    
    // MARK: - ACTIONS
    
    
    @IBAction func HandleInkAction(_ sender: AnyObject) {
        if (textView.text.characters.count > 0) {
            audioHelper.playClickSound()
            performSegue(withIdentifier: "composeToShare", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Wait!", message: "Please type a message", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func pulseButton() {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.66;
        pulseAnimation.toValue = NSNumber(value: 1.03 as Float);
        pulseAnimation.fromValue = NSNumber(value: 0.97 as Float)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        self.generateButton!.layer.add(pulseAnimation, forKey: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if (textView.text != composeMessageTextViewPlaceholder) {
            pulseButton()
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        _selectedPointSize = Int(sender.value)
        fontSizeLabel.text = String(_pointSizeStrings[_selectedPointSize])
        textView!.font = textView!.font!.withSize(CGFloat(_pointSizeOptions[Int(sender.value)]))
    }
    
    // MARK: - TEXTVIEW DELEGATE
    
    func textViewDidChange(_ textView: UITextView) {
        generateButton?.isEnabled = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text == composeMessageTextViewPlaceholder) {
            textView.text = ""
            textView.textColor = SharedMyInkValues.MyInkLightColor
        }
        return true
    }

    
    // MARK: - KEYBOARD

    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageController.handleKeyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageController.handleKeyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardDidShow(_ notification: Notification) {
        let info = notification.userInfo as? [String:AnyObject]
        if info != nil && textView != nil {
            let kbRect = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            bottomConstraint.constant = kbRect.height + 20
            textView!.scrollRangeToVisible(textView!.selectedRange)
        }
        animateConstraintChanges()
    }

    func handleKeyboardDidHide(_ notification: Notification) {
        bottomConstraint.constant = 20
        animateConstraintChanges()
    }

    fileprivate func animateConstraintChanges() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
