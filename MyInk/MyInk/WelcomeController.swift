//
//  WelcomeController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-25.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit
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


class WelcomeController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textfield: UITextField?
    @IBOutlet weak var mButton: UIButton!
    var audioHelper = AudioHelper()
    
    fileprivate var _fontMessageRenderer:FontMessageRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textfield!.delegate = self
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.shared.delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _fontMessageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: SharedMyInkValues.MyInkWatermark)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textfield?.text = ""
        mButton.isEnabled = false
        mButton.isHidden = true
        self.mButton!.layer.removeAllAnimations()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, animations: {
            self.textfield?.becomeFirstResponder()
        })
        UIView.animate(withDuration: 2.0, animations: {
            self.mButton.alpha = 1.0
            self.mButton.isHidden = false
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ExampleController {
            let vc = segue.destination as! ExampleController
            //let message = textfield?.text
            
            if(textfield?.text!.characters.count > 0) {
                var message = ""
                if(textfield?.text!.characters.count < 30) {
                    message += "          "
                    message += (textfield?.text!)!
                    message += "          "
                }
                else {
                    message = (textfield?.text)!
                }
                if(_fontMessageRenderer != nil) {
                    let calculatedLineHeight = 30.0 * SharedMyInkValues.FontPointSizeToPixelRatio
                    let imageMessage = _fontMessageRenderer!.render(message: message, width: 750, lineHeight: calculatedLineHeight, backgroundColor: UIColor.clear)
                    if imageMessage != nil {
                        vc.loadImage(imageMessage!)
                    }
                }
            }
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
        self.mButton!.layer.add(pulseAnimation, forKey: nil)
    }
    
    
    // MARK: - Delegate Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let empty = (textfield?.text == "")
        if(!empty) {
            mButton?.isEnabled = true
            pulseButton()
        }
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let empty = (textfield?.text == "")
        if(!empty) {
            mButton?.isEnabled = true
            pulseButton()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func HandleInkButton(_ sender: AnyObject) {
        if(textfield?.text?.characters.count > 0) {
            audioHelper.playClickSound()
            performSegue(withIdentifier: "segueWelcomeToExample", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Wait!", message: "Please type a message", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 

}
