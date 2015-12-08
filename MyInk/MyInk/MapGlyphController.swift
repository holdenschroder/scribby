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
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        textfield?.clearsOnInsertion = true
        textfield?.text = ""
        textfield!.layer.cornerRadius = 3.0
        textfield!.layer.borderWidth = 1.0
        textfield!.layer.borderColor = UIColor.darkGrayColor().CGColor
        textfield!.layer.masksToBounds = true
        
        saveBtn.enabled = false
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureMapGlyph)
    }
    
    func setCallback(callback:InputCallback) {
        _callback = callback
    }
    
    func popVC() {
        let alert = UIAlertController(title: "Saved", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatch_time(dispatchTime, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[0], animated: true);
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func Handle_SaveButton(sender: AnyObject) {
        if(_callback != nil) {
            let string:String? = textfield!.text
            _callback!(value: string)
            //popVC()
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