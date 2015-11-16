//
//  SetupCharacterView.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-11.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import Crashlytics

class SetupCharacterController : UIViewController, UIScrollViewDelegate {
    @IBOutlet var imageView:UIPanZoomImageView?
    @IBOutlet var lineReference:UIImageView?
    @IBOutlet var debugView:UIView?
    private var _baseImage:UIImage?
    
    @IBInspectable var topLinePercent:CGFloat = 0.125
    @IBInspectable var bottomLinePercent:CGFloat = 0.625
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(isMovingToParentViewController()) {
            imageView?.image = _baseImage
        }
        debugView?.hidden = true
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureSetupCharacter)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParentViewController() {
            _baseImage = nil
            imageView?.image = nil
        }
    }
    
    func LoadCharacter(image:UIImage) {
        let croppedImage = ImageCropUtility.CropImageToAlpha(image)
        _baseImage = croppedImage
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        scrollView.scrollEnabled = true
    }
    
    @IBAction func HandleDebugButton(sender: AnyObject) {
        debugView?.hidden = false
        var spacingBounds = getSpacingBounds()
        let imageBounds = imageView!.convertRect(imageView!.lastContentArea!, toView: debugView!.superview)
        spacingBounds = spacingBounds * imageBounds.size
        spacingBounds.origin += imageBounds.origin
        debugView?.frame = spacingBounds
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.destinationViewController is MapGlyphController {
            let mapGlyph = segue.destinationViewController as! MapGlyphController
            mapGlyph.setCallback(HandleMapGlyphCallback)
        }
    }
    
    private func HandleMapGlyphCallback(value:String?) {
        if value == nil {
            return
        }
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        if(currentAtlas!.hasGlyphMapping(value!)) {
            let alert = UIAlertController(title: "Already Exists", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Replace", style: UIAlertActionStyle.Default, handler: { action in
                self.SaveGlyph(value!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            //We need to wait a bit to present the alert because we can't present it before this view is represented
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
               self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else if currentAtlas?.glyphs.count >= currentAtlas?.glyphLimit {
            let alert = UIAlertController(title: "Atlas Full", message: "Sorry the font atlas can only hold \(currentAtlas!.glyphLimit) characters.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else {
            SaveGlyph(value!)
        }
    }
    
    private func SaveGlyph(mapping:String) {
        let spacingBounds = getSpacingBounds()
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        
        atlas?.AddGlyph(mapping, image: imageView!.image!, spacingCoords: spacingBounds)
        
        navigationController?.popViewControllerAnimated(true)
        if atlas != nil {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventMappedCharacter, parameters:
                [
                    SharedMyInkValues.kEventMappedCharacterArgMapped:mapping,
                    SharedMyInkValues.kEventMappedCharacterArgNumAtlasChars:String(atlas!.glyphs.count),
                    SharedMyInkValues.kEventMappedCharacterArgCaptureType:"Camera"
                ])
        }
    }
    
    private func getSpacingBounds() -> CGRect {
        let imageSize = lineReference!.image!.size
        var reference_rect = lineReference!.convertRectFromImage(CGRectMake(0, imageSize.height * topLinePercent, imageSize.width, imageSize.height * (bottomLinePercent - topLinePercent)))
        reference_rect = lineReference!.convertRect(reference_rect, toView: imageView!.superview)
        let image_rect = imageView!.convertRect(imageView!.lastContentArea!, toView: imageView!.superview)
        
        var examine_topline = reference_rect.origin.y + (reference_rect.height * 0.5)
        if image_rect.origin.y > examine_topline {
            examine_topline = image_rect.origin.y
            if examine_topline > reference_rect.origin.y + (reference_rect.height * 0.5) {
                examine_topline = reference_rect.origin.y + (reference_rect.height * 0.5)
            }
        }
        var examine_bottomline = reference_rect.origin.y + (reference_rect.height)
        if image_rect.origin.y + image_rect.height < examine_bottomline  {
            examine_bottomline = image_rect.origin.y + image_rect.height
        }
        var examine_area = CGRectMake(image_rect.origin.x, examine_topline, image_rect.width, examine_bottomline - examine_topline)
        examine_area.origin -= image_rect.origin
        examine_area = examine_area / image_rect.size
        let contentBounds = imageView!.image!.FindContentArea(examine_area)
        return CGRectMake(contentBounds.origin.x, (image_rect.origin.y - reference_rect.origin.y) / reference_rect.height, contentBounds.width, image_rect.height / reference_rect.height)
    }
}