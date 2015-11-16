//
//  UIDrawCaptureView.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-22.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

/**
    UIDrawCaptureView

    A UIDrawView that provides a function to allow the user to save the image to a Font Atlas
*/
class UIDrawCaptureView: UIDrawView {
    /** This image view is used as a reference when determining the positioning of the drawn character. It determines line spacing */
    @IBOutlet var referenceImage:UIImageView?
    
    @IBInspectable var topLinePercent:CGFloat = 0.166
    @IBInspectable var bottomLinePercent:CGFloat = 0.834
    
    func save(mapping:String, captureType:String, saveAtlas:Bool = true) -> Bool {
        let imageSize = referenceImage!.image!.size
        var reference_rect = CGRectMake(0, imageSize.height * topLinePercent, imageSize.width, imageSize.height * (bottomLinePercent - topLinePercent))
        reference_rect = referenceImage!.convertRectFromImage(reference_rect);
        reference_rect = referenceImage!.convertRect(reference_rect, toView:self)
        
        let myImage = getImage()
        
        var glyphArea = myImage.FindContentArea(CGRect(x: 0, y: 0, width: 1, height: 1))
        glyphArea = glyphArea * myImage.size
        let croppedImage = myImage.CropImage(glyphArea)
        
        var examine_topline = reference_rect.origin.y
        if glyphArea.origin.y > examine_topline {
            examine_topline = glyphArea.origin.y
            if examine_topline > reference_rect.origin.y + reference_rect.height {
                examine_topline = reference_rect.origin.y + reference_rect.height
            }
        }
        var examine_bottomline = reference_rect.origin.y + reference_rect.height
        if glyphArea.origin.y + glyphArea.height < examine_bottomline  {
            examine_bottomline = glyphArea.origin.y + glyphArea.height
        }
        var examine_area = CGRectMake(glyphArea.origin.x, examine_topline, glyphArea.width, examine_bottomline - examine_topline)
        examine_area.origin -= glyphArea.origin
        examine_area = examine_area / glyphArea.size
        let contentBounds = croppedImage.FindContentArea(examine_area)
        let spacingBounds = CGRectMake(contentBounds.origin.x, (glyphArea.origin.y - reference_rect.origin.y)/reference_rect.height, contentBounds.width, glyphArea.height / reference_rect.height)
        
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        atlas?.AddGlyph(mapping, image: croppedImage, spacingCoords: spacingBounds, autoSave: saveAtlas)
        
        if atlas != nil {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventMappedCharacter, parameters:
                [
                    SharedMyInkValues.kEventMappedCharacterArgMapped:mapping,
                    SharedMyInkValues.kEventMappedCharacterArgNumAtlasChars:String(atlas!.glyphs.count),
                    SharedMyInkValues.kEventMappedCharacterArgCaptureType:captureType
                ])
            
            return true
        }
        return false
    }
}