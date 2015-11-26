//
//  LibraryItemController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-16.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit

class LibraryItemController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: VARS
    
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    private var lastImage:UIImage?
    var _mAtlasGlyph: FontAtlasGlyph?
    var captureView:CaptureWordSelectController!
    

    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\("Edit:") \(_mAtlasGlyph!.mapping.uppercaseString)"
        let camButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "openCapture")
        navigationItem.rightBarButtonItem = camButton
        
        captureView = storyboard?.instantiateViewControllerWithIdentifier("CaptureView") as? CaptureWordSelectController
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryItem)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    

    
    // MARK: CAPTURE
    
    func showCaptureView(image:UIImage) {
        self.captureView.loadImage(image)
        self.captureView._mAtlasGlyph = _mAtlasGlyph
        self.showViewController(self.captureView, sender: self)
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
        
        let ctx:CGContextRef = CGBitmapContextCreate(nil, Int(imageSize.width), Int(imageSize.height),
            CGImageGetBitsPerComponent(image.CGImage), 0,
            CGImageGetColorSpace(image.CGImage),
            CGImageGetBitmapInfo(image.CGImage).rawValue)!;
        CGContextConcatCTM(ctx, imageTransform);
        switch (imageOrientation) {
        case .Left:
            fallthrough
        case .LeftMirrored:
            fallthrough
        case .Right:
            fallthrough
        case .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,imageSize.height,imageSize.width), image.CGImage);
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,imageSize.width,imageSize.height), image.CGImage);
        }
        
        let cgimg = CGBitmapContextCreateImage(ctx);
        let img = UIImage(CGImage: cgimg!)//UIImage imageWithCGImage:cgimg]
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        showCaptureView(img)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryPhotoTaken)
    }
    
    
    // MARK: ACTIONS
    
    func openCapture() {
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
            showCaptureView(UIImage(named: "CapturePositioningTest")!)
        }
    }
    
    @IBAction func mapAction(sender: AnyObject) {
        self.drawCaptureView?.save((_mAtlasGlyph?.mapping)!, captureType:"Touch")
        self.drawCaptureView?.clear()
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func clearAction(sender: AnyObject) {
        self.drawCaptureView?.clear()
    }
    
    
}
