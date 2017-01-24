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
    @IBOutlet var referenceImage: UIImageView?
    
    @IBInspectable var topLinePercent: CGFloat =  0.166 //-0.166
    @IBInspectable var bottomLinePercent: CGFloat = 0.834 //0.66
    
    func save(_ mapping: String, captureType: String, saveAtlas: Bool = true) -> Bool {
        let imageSize = referenceImage!.image!.size
        var reference_rect = CGRect(x: 0, y: imageSize.height * topLinePercent, width: imageSize.width, height: imageSize.height * (bottomLinePercent - topLinePercent))
        reference_rect = referenceImage!.convertRect(fromImage: reference_rect);
        reference_rect = referenceImage!.convert(reference_rect, to:self)
        
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
        var examine_area = CGRect(x: glyphArea.origin.x, y: examine_topline, width: glyphArea.width, height: examine_bottomline - examine_topline)
        examine_area.origin -= glyphArea.origin
        examine_area = examine_area / glyphArea.size
        let contentBounds = croppedImage.FindContentArea(examine_area)
        let spacingBounds = CGRect(x: contentBounds.origin.x, y: (glyphArea.origin.y - reference_rect.origin.y)/reference_rect.height, width: contentBounds.width, height: glyphArea.height / reference_rect.height)
        
        let atlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
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
    
    func loadImage(_ image: UIImage, rect: CGRect) {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        let imageSize = mainImageView.bounds.size * (bottomLinePercent - topLinePercent)
        let imageRect = CGRect(origin: rect.origin * imageSize, size: imageSize)
        imageRect.offsetBy(dx: -imageRect.origin.x, dy: topLinePercent * imageSize.height)
        image.draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
