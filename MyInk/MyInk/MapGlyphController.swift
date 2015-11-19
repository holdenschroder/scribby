//
//  MapGlyphController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-13.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class MapGlyphController:UIViewController, UITextFieldDelegate {
    typealias InputCallback = (value:String?) -> Void
    
    @IBOutlet var textfield:UITextField?
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    private var _callback:InputCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureMapGlyph)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false

        textfield?.clearsOnInsertion = true
        textfield?.text = ""
        textfield!.layer.cornerRadius = 3.0
        textfield!.layer.borderWidth = 1.0
        textfield!.layer.borderColor = UIColor.darkGrayColor().CGColor
        textfield!.layer.masksToBounds = true
        
        saveBtn.enabled = false
        
    }
    
    func setCallback(callback:InputCallback) {
        _callback = callback
    }
    
    @IBAction func Handle_SaveButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
        if(_callback != nil) {
            let string:String? = textfield!.text
            _callback!(value: string)
        }
    }
    
    @IBAction func Handle_TextFieldChanged(sender: UITextField) {
        //Enforce a single character
        if sender.text?.isEmpty == false && sender.text?.characters.count > 1 {
            var text:String = sender.text!
            text = text.substringFromIndex(text.endIndex.advancedBy(-1))
            sender.text = text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveBtn.enabled = textField.text?.isEmpty == false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        saveBtn.enabled = false
        textField.resignFirstResponder()
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}