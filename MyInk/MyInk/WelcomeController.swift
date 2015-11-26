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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mTextField!.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.5, animations: {
            self.mButton.alpha = 1.0
        })
    }

    
    // MARK: - Delegate Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //print("textFieldShouldEndEditing ", textField.text)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        mTextField!.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldDidEndOnExit(sender: UITextField) {
        print("textFieldDidEndOnExit ", mTextField!.text)
        mTextField!.resignFirstResponder()
        sender.resignFirstResponder()
    }

    
    @IBAction func HandleInkButton(sender: AnyObject) {
        
    }
 

}
