//
//  CaptureTouchCharacter.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-16.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class CaptureTouchController:UIViewController {
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    private var lastImage:UIImage?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        if isMovingToParentViewController() {
            drawCaptureView?.clear()
        }
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureTouch)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.destinationViewController is MapGlyphController {
            let mapGlyphController = segue.destinationViewController as! MapGlyphController
            mapGlyphController.setCallback(HandleMapGlyphCallback)
        }
    }
    
    private func HandleMapGlyphCallback(value:String?) {
        if value == nil {
            return
        }
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        if(currentAtlas!.hasGlyphMapping(value!)) {
            let alert = UIAlertController(title: "Already Exists", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Replace", style: .Default, handler: { action in
                self.drawCaptureView?.save(value!, captureType:"Touch")
                self.drawCaptureView?.clear()
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatch_time(dispatchTime, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else if currentAtlas?.glyphs.count >= currentAtlas?.glyphLimit {
            let alert = UIAlertController(title: "Atlas Full", message: "Sorry the font atlas can only hold \(currentAtlas!.glyphLimit) characters.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else {
            drawCaptureView?.save(value!, captureType:"Touch")
            drawCaptureView?.clear()
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatch_time(dispatchTime, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}