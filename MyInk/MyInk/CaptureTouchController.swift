//
//  CaptureTouchCharacter.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-16.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

class CaptureTouchController: UIViewController {
    @IBOutlet var drawCaptureView: UIDrawCaptureView?
    @IBOutlet weak var characterTextField: UITextField!
    @IBOutlet weak var overlayImageView: UIImageView!

    @IBAction func textFieldChanged(_ sender: UITextField) {
        var text = sender.text ?? ""
        if text.characters.count > 1 {
            text = String(text.characters.first!)
        } else if text == " " {
            text = ""
        }
        sender.text = text
        if text.characters.count == 1 {
            changeTextWindowFocus(on: false)
        }
    }

    fileprivate var lastImage: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        if isMovingToParentViewController {
            drawCaptureView?.clear()
        }
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureTouch)

        setUpTextFieldAppearance()
        characterTextField.textContentType = UITextContentType.scribbyInput

        if SharedMyInkValues.doNotShowCreateTutorialScreen {
            dismissOverlay(animated: false)
            changeTextWindowFocus(on: true)
        } else {
            setUpOverlayImage()
        }
    }

    private func changeTextWindowFocus(on: Bool) {
        if on {
            characterTextField.becomeFirstResponder()
            drawCaptureView?.isUserInteractionEnabled = false
        } else {
            characterTextField.resignFirstResponder()
            drawCaptureView?.isUserInteractionEnabled = true
        }
    }

    func overlayImageViewTapped(_ sender: UITapGestureRecognizer) {
        dismissOverlay(animated: true)
    }

    private func setUpOverlayImage() {
        overlayImageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayImageViewTapped(_:)))
        overlayImageView.addGestureRecognizer(tapRecognizer)
    }

    private func dismissOverlay(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0, animations: {
            self.overlayImageView.alpha = 0
        }, completion: { _ in
            self.overlayImageView.removeFromSuperview()

            if animated {
                let controller = UIAlertController(title: "Every time you come to this screen, we can show you those instructions.", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.changeTextWindowFocus(on: true)
                })
                let notAgainAction = UIAlertAction(title: "I got it! Don't show them again.", style: .destructive, handler: { _ in
                    self.changeTextWindowFocus(on: true)
                    SharedMyInkValues.doNotShowCreateTutorialScreen = true
                })
                controller.addAction(okAction)
                controller.addAction(notAgainAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    private func setUpTextFieldAppearance() {
        characterTextField.layer.cornerRadius = 10
        characterTextField.layer.borderColor = SharedMyInkValues.MyInkDarkColor.cgColor
        characterTextField.layer.borderWidth = 2.0
    }


    @IBAction func assignButtonPressed(_ sender: Any) {
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas

        if currentAtlas?.glyphs.count >= currentAtlas?.glyphLimit {
            let alert = UIAlertController(title: "Atlas Full", message: "Sorry the font atlas can only hold \(currentAtlas!.glyphLimit) characters.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.present(alert, animated: true, completion: nil)
            })
        } else {
            _ = drawCaptureView?.save(characterTextField.text!, captureType: "Touch")
            drawCaptureView?.clear()
            drawCaptureView?.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC) * 0.2, execute: { () -> Void in
                self.characterTextField.text = ""
                self.changeTextWindowFocus(on: true)
            })
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

extension CaptureTouchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}
