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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MapGlyphController: UIViewController, UITextFieldDelegate {
    typealias InputCallback = (_ value: String?) -> Void
    
    @IBOutlet var textfield: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    fileprivate var _callback: InputCallback?


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        textfield.clearsOnInsertion = true
        textfield.text = ""
        textfield.layer.cornerRadius = 3.0
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.darkGray.cgColor
        textfield.layer.masksToBounds = true
        
        saveBtn.isEnabled = false
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureMapGlyph)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.textfield.becomeFirstResponder()
        })
    }
    
    func setCallback(_ callback:@escaping InputCallback) {
        _callback = callback
    }
    
    func popVC() {
        let alert = UIAlertController(title: "Saved", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[0], animated: true);
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func Handle_SaveButton(_ sender: AnyObject) {
        if(_callback != nil) {
            let string: String? = textfield!.text
            _callback!(string)
        }
    }
    
    @IBAction func Handle_TextFieldChanged(_ sender: UITextField) {
        //Enforce a single character
        if sender.text?.characters.count > 1 {
            sender.text = String(sender.text!.characters.first!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveBtn.isEnabled = textField.text?.isEmpty == false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        saveBtn.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
