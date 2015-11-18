//
//  ComposeMessageController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class ComposeMessageController: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var textView:UITextView?
    @IBOutlet var generateButton:UIBarButtonItem?
    @IBOutlet var pointSizePicker:UIPickerView?
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    private let _pointSizeOptions:[Float] = [10, 12, 14, 16, 18, 20, 24, 28, 32]
    private var _fontMessageRenderer:FontMessageRenderer?
    private var _selectedPointSize = 3
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        if isMovingToParentViewController() {
            textView?.text = ""
        }
        if textView != nil {
            generateButton?.enabled = textView!.hasText()
            textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
        }
        
        if pointSizePicker != nil {
            pointSizePicker?.selectRow(_selectedPointSize, inComponent: 0, animated: false)
        }
        
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
    
    //-- UITextViewDelegate Methods
    
    func textViewDidChange(textView: UITextView) {
        generateButton?.enabled = !textView.text.isEmpty
    }
    
    //-- UIPickerViewDataSource Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _pointSizeOptions.count
    }
    
    //-- UIPickerViewDelegate Methods
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(_pointSizeOptions[row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _selectedPointSize = row
        textView!.font = textView!.font!.fontWithSize(CGFloat(_pointSizeOptions[_selectedPointSize]))
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
        }
    }
    
    func handleKeyboardDidHide(notification:NSNotification) {
        bottomConstraint.constant = 0
        textView?.layoutIfNeeded()
    }
}