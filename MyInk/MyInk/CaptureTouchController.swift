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


class CaptureTouchController:UIViewController {
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    fileprivate var lastImage:UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        if isMovingToParentViewController {
            drawCaptureView?.clear()
        }
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureTouch)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is MapGlyphController {
            let mapGlyphController = segue.destination as! MapGlyphController
            mapGlyphController.setCallback(HandleMapGlyphCallback)
        }
    }
    
    fileprivate func HandleMapGlyphCallback(_ value:String?) {
        if value == nil {
            return
        }
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        if(currentAtlas!.hasGlyphMapping(value!)) {
            let alert = UIAlertController(title: "Already Exists", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Replace", style: .default, handler: { action in
                self.drawCaptureView?.save(value!, captureType:"Touch")
                self.drawCaptureView?.clear()
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    self.navigationController?.popViewController(animated: true)
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.present(alert, animated: true, completion: nil)
            })
        }
        else if currentAtlas?.glyphs.count >= currentAtlas?.glyphLimit {
            let alert = UIAlertController(title: "Atlas Full", message: "Sorry the font atlas can only hold \(currentAtlas!.glyphLimit) characters.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            drawCaptureView?.save(value!, captureType:"Touch")
            drawCaptureView?.clear()
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
