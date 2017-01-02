//
//  SetupCharacterView.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-11.
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


class SetupCharacterController : UIViewController, UIScrollViewDelegate {
    @IBOutlet var imageView:UIPanZoomImageView?
    @IBOutlet var lineReference:UIImageView?
    @IBOutlet var debugView:UIView?
    fileprivate var _baseImage:UIImage?
    var _mAtlasGlyph: FontAtlasGlyph?
    
    @IBInspectable var topLinePercent:CGFloat = 0.125
    @IBInspectable var bottomLinePercent:CGFloat = 0.625
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        if(isMovingToParentViewController) {
            imageView?.image = _baseImage
        }
        debugView?.isHidden = true
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureSetupCharacter)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParentViewController {
            _baseImage = nil
            imageView?.image = nil
        }
    }
    
    func LoadCharacter(_ image:UIImage) {
        let croppedImage = ImageCropUtility.CropImageToAlpha(image)
        _baseImage = croppedImage
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = true
    }
    
    @IBAction func HandleDebugButton(_ sender: AnyObject) {
        debugView?.isHidden = false
        var spacingBounds = getSpacingBounds()
        let imageBounds = imageView!.convert(imageView!.lastContentArea!, to: debugView!.superview)
        spacingBounds = spacingBounds * imageBounds.size
        spacingBounds.origin += imageBounds.origin
        debugView?.frame = spacingBounds
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is MapGlyphController {
            let mapGlyph = segue.destination as! MapGlyphController
            mapGlyph.setCallback(HandleMapGlyphCallback)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        var should = true
        if identifier == "setupToMapGlyph" {
            if((_mAtlasGlyph) != nil) {
                SaveGlyph((_mAtlasGlyph?.mapping)!)
                should = false
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true);
            }
            else {
                should = true
            }
        }
        else {
            should = true
        }
        return should
    }
    
    fileprivate func HandleMapGlyphCallback(_ value:String?) {
        if value == nil {
            return
        }
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        if(currentAtlas!.hasGlyphMapping(value!)) {
            let alert = UIAlertController(title: "Already Exists", message: "There is a glyph already mapped to that character, would you like to replace it with this one?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Replace", style: UIAlertActionStyle.default, handler: { action in
                self.SaveGlyph(value!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
               self.present(alert, animated: true, completion: nil)
            })
        }
        else if currentAtlas?.glyphs.count >= currentAtlas?.glyphLimit {
            let alert = UIAlertController(title: "Atlas Full", message: "Sorry the font atlas can only hold \(currentAtlas!.glyphLimit) characters.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            SaveGlyph(value!)
        }
    }
    
    fileprivate func SaveGlyph(_ mapping:String) {
        let spacingBounds = getSpacingBounds()
        let atlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        atlas?.AddGlyph(mapping, image: imageView!.image!, spacingCoords: spacingBounds)
        navigationController?.popViewController(animated: true)
        if atlas != nil {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventMappedCharacter, parameters:
                [
                    SharedMyInkValues.kEventMappedCharacterArgMapped:mapping,
                    SharedMyInkValues.kEventMappedCharacterArgNumAtlasChars:String(atlas!.glyphs.count),
                    SharedMyInkValues.kEventMappedCharacterArgCaptureType:"Camera"
                ])
        }
    }
    
    fileprivate func getSpacingBounds() -> CGRect {
        let imageSize = lineReference!.image!.size
        var reference_rect = lineReference!.convertRect(fromImage: CGRect(x: 0, y: imageSize.height * topLinePercent, width: imageSize.width, height: imageSize.height * (bottomLinePercent - topLinePercent)))
        reference_rect = lineReference!.convert(reference_rect, to: imageView!.superview)
        let image_rect = imageView!.convert(imageView!.lastContentArea!, to: imageView!.superview)
        
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
        var examine_area = CGRect(x: image_rect.origin.x, y: examine_topline, width: image_rect.width, height: examine_bottomline - examine_topline)
        examine_area.origin -= image_rect.origin
        examine_area = examine_area / image_rect.size
        let contentBounds = imageView!.image!.FindContentArea(examine_area)
        return CGRect(x: contentBounds.origin.x, y: (image_rect.origin.y - reference_rect.origin.y) / reference_rect.height, width: contentBounds.width, height: image_rect.height / reference_rect.height)
    }
}
