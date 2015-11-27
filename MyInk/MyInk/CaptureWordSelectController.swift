//
//  CaptureWordSelectView.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-05-14.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

class CaptureWordSelectController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView:UIImageView?
    @IBOutlet var selectionView:UIDrawSelectionView?
    @IBOutlet var colorTest:UIView?
    @IBOutlet var debugCrosshair:UIImageView?
    @IBOutlet var toleranceSlider:UISlider?
    @IBOutlet var debugRect:UIView?
    @IBOutlet var selectBtn:UIBarButtonItem?
    
    private var cameraImage:UIImage?
    private var inkColour:CIColor?
    var _mAtlasGlyph: FontAtlasGlyph?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        imageView?.userInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)
        debugCrosshair?.hidden = true
        debugRect?.hidden = true
        selectBtn?.enabled = false
        
        imageView?.image = cameraImage
        selectionView!.addOnChangeListener(handleSelectionChange)
        
        if(cameraImage != nil) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                self.inkColour = ImageCropUtility.FindInkColor(self.cameraImage!)
            })
        }
    }
    
    func loadImage(image:UIImage) {
        cameraImage = image
        imageView?.image = cameraImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        selectionView?.clearImage()
        selectBtn?.enabled = false
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureWordSelect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let error = NSError?()
        Flurry.logError(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect, message: "Memory Warning", error: error)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if self.isMovingFromParentViewController() {
            cameraImage = nil
            imageView?.image = nil
            selectionView?.clearImage()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.destinationViewController is CaptureCharacterSelectController {
            let processView = segue.destinationViewController as! CaptureCharacterSelectController
            if((_mAtlasGlyph) != nil) {
                processView._mAtlasGlyph = _mAtlasGlyph
            }
            let cropImage = selectionView!.CropImageBySelection(imageView!)
            if(cropImage != nil) {
                processView.LoadImage(cropImage!, inkColor: inkColour)
            }
        }
    }
    
    @IBAction func openCamera(sender: UIButton) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            dispatch_async(dispatch_get_main_queue(), {
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imgPicker, animated: true, completion: nil)
            })
        }
        else //Load Test Image
        {
            imageView?.image = UIImage(named: "YopTest")
            selectBtn?.enabled = true
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let imageSize = image.size
        var imageTransform:CGAffineTransform = CGAffineTransformIdentity
        //Build a transform to offset and rotate the rect depending on the orientation
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.DownMirrored:
            fallthrough
        case UIImageOrientation.Down:
            imageTransform = CGAffineTransformTranslate(imageTransform, imageSize.width, imageSize.height)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI))
        case UIImageOrientation.LeftMirrored:
            fallthrough
        case UIImageOrientation.Left:
            imageTransform = CGAffineTransformTranslate(imageTransform, imageSize.width, 0)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_2))
        case UIImageOrientation.RightMirrored:
            fallthrough
        case UIImageOrientation.Right:
            imageTransform = CGAffineTransformTranslate(imageTransform, 0, imageSize.height)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(-M_PI_2))
        default:
            break
        }

        //Compensate for Mirrored orientations
        switch(imageOrientation)
        {
        case UIImageOrientation.UpMirrored:
            fallthrough
        case UIImageOrientation.DownMirrored:
            imageTransform = CGAffineTransformTranslate(imageTransform, imageSize.width, 0)
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
        case UIImageOrientation.LeftMirrored:
            fallthrough
        case UIImageOrientation.RightMirrored:
            imageTransform = CGAffineTransformTranslate(imageTransform, imageSize.height, 0)
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
        default:
            break
        }

        var transformedImage = CIImage(CGImage: image.CGImage!)
        transformedImage = transformedImage.imageByApplyingTransform(imageTransform)
        imageView?.image = UIImage(CIImage: transformedImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
        selectBtn?.enabled = true
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCapturePhotoTaken)
    }

    func resizeImage(image:UIImage, newSize:CGSize) -> UIImage
    {
        var ratio:CGFloat = 0.0
        var delta:CGFloat = 0.0
        var offset = CGPoint.zero

        let sz = CGSizeMake(newSize.width, newSize.width);
        
        if(image.size.width > image.size.height) {
            ratio = newSize.width / image.size.width;
            delta = (ratio*image.size.width - ratio*image.size.height);
            offset = CGPointMake(delta/2, 0);
        }
        else {
            ratio = newSize.height / image.size.height;
            delta = (ratio*image.size.height - ratio*image.size.width);
            offset = CGPointMake(0, delta/2);
        }
    
        let clipRect = CGRectMake(-offset.x, -offset.y,
                (ratio * image.size.width) + delta,
                (ratio * image.size.height) + delta);
        
        UIGraphicsBeginImageContextWithOptions(sz, true, 0.0);
        UIRectClip(clipRect);
        image.resizingMode
        image.drawInRect(clipRect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    func GetPixelColor(view:UIImageView, position:CGPoint) -> CIColor {
        let image = view.image!
        var imgPos = view.convertPointFromView(position)
        var imgRect = CGRect(origin: CGPointZero, size: image.size)
        
        var imageTransform:CGAffineTransform = CGAffineTransformIdentity
        
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.DownMirrored:
            fallthrough
        case UIImageOrientation.Down:
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_4))
        case UIImageOrientation.LeftMirrored:
            fallthrough
        case UIImageOrientation.Left:
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(-M_PI_2))
        case UIImageOrientation.RightMirrored:
            fallthrough
        case UIImageOrientation.Right:
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_2))
            imgPos.x = imgRect.width - imgPos.x
        default:
            break
        }
        
        imgPos = CGPointApplyAffineTransform(imgPos, imageTransform)
        imgRect = CGRectApplyAffineTransform(imgRect, imageTransform)
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 1
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
        if(imgPos.x > -1 && imgPos.x < imgRect.width && imgPos.y > -1 && imgPos.y < imgRect.height) {
            let pixelInfo: Int = ((Int(imgRect.width) * Int(imgPos.y)) + Int(imgPos.x)) * 4
            
            r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        }
        
        return CIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func GetImagePos(view:UIImageView, viewPosition:CGPoint) -> CGPoint {
        let image = view.image!
        let imgSize = image.size
        let viewSize = view.bounds.size
        
        let ratioX = viewSize.width / imgSize.width
        let ratioY = viewSize.height / imgSize.height
        let scale = min(ratioX, ratioY)
        
        var finalPos = viewPosition
        finalPos.x -= (viewSize.width - imgSize.width * scale) / 2.0
        finalPos.y -= (viewSize.height - imgSize.height * scale) / 2.0
        
        finalPos.x /= scale
        finalPos.y /= scale
        
        return finalPos
    }
    
    func handleSelectionChange(selectionView:UIDrawSelectionView, cleared:Bool) -> Void {
        selectBtn?.enabled = !cleared
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}

