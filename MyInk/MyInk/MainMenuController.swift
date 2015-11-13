//
//  MainMenuController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-11.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import Foundation

class MainMenuController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureView:CaptureWordSelectController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureView = storyboard?.instantiateViewControllerWithIdentifier("CaptureView") as? CaptureWordSelectController
    
        let tutorialState = (UIApplication.sharedApplication().delegate as! AppDelegate).tutorialState
        if tutorialState != nil && tutorialState!.isTutorialFlagSet(TutorialState.TutorialFlags.StartingPhrase) == false {
            MyInkAnalytics.StartTimedEvent(SharedMyInkValues.Flurry_FirstPhraseEvent, parameters: ["Resuming":String(Int(tutorialState!.wordIndex) > 0)])
            let welcomeScreen = storyboard?.instantiateViewControllerWithIdentifier("WelcomeScreen")
            if welcomeScreen != nil {
                self.presentViewController(welcomeScreen!, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent("Screen Loaded - Main Menu")
    }
    
    //MARK: Button Handlers
    
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
            showCaptureView(UIImage(named: "CapturePositioningTest")!)
        }
        
    }
    
    @IBAction func openPhraseCapture(sender:AnyObject) {
        //TODO: Redesign the phrase view so that it can be better used for non-tutorial capture flows
        
        //If the user can trigger this we can assume they are not in the initial tutorial and thus we should reset the word to give a consistent flow
        let tutorialState = (UIApplication.sharedApplication().delegate as! AppDelegate).tutorialState
        tutorialState?.wordIndex = 0
        
        let phraseScreen = storyboard?.instantiateViewControllerWithIdentifier("TutorialPhrase")
        if phraseScreen != nil {
            self.presentViewController(phraseScreen!, animated: true, completion: nil)
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
    }
    
    func showCaptureView(image:UIImage) {
        self.captureView.loadImage(image)
        self.showViewController(self.captureView, sender: self)
    }
    
    //MARK: Interface Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
}