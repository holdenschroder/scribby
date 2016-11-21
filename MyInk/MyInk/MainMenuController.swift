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
    
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var libraryBtn: UIButton!
    @IBOutlet weak var tutorialBtn: UIButton!
    
    var audioHelper = AudioHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureView = storyboard?.instantiateViewControllerWithIdentifier("CaptureView") as? CaptureWordSelectController
        
        writeBtn.setImage(UIImage(named: "icon_compose_tapped"), forState: .Selected)
        createBtn.setImage(UIImage(named: "icon_touch_tapped"), forState: .Selected)
        libraryBtn.setImage(UIImage(named: "icon_library_tapped"), forState: .Selected)
        tutorialBtn.setImage(UIImage(named: "icon_tutorial_tapped"), forState: .Selected)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        writeBtn.selected = false
        createBtn.selected = false
        libraryBtn.selected = false
        tutorialBtn.selected = false

        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedMainMenu)
    }
    
    //MARK: Button Handlers
    
    
    @IBAction func HandleWriteButtonAction(sender: AnyObject) {
        audioHelper.playClickSound()
        writeBtn.selected = true
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Compose") as? ComposeMessageController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleCreateButtonAction(sender: AnyObject) {
        audioHelper.playClickSound()
        createBtn.selected = true
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Capture") as? CaptureTouchController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleLibraryButtonAction(sender: AnyObject) {
        audioHelper.playClickSound()
        libraryBtn.selected = true
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Library") as? LibraryCollectionController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleTutorialButtonAction(sender: AnyObject) {
        audioHelper.playClickSound()
        tutorialBtn.selected = true
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Instructions") as? InstallationInstructions
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
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
            showCaptureView(UIImage(named: "CapturePositioningTest")!)
        }
        
    }
    
    @IBAction func openPhraseCapture(sender:AnyObject) {
        let tutorialState = (UIApplication.sharedApplication().delegate as! AppDelegate).tutorialState
        tutorialState?.wordIndex = 0
        MyInkAnalytics.StartTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: ["Resuming":String(Int(tutorialState!.wordIndex) > 0)])
        presentViewController(UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewControllerWithIdentifier("TutorialIntro") as UIViewController, animated: true, completion: nil)
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
            CGImageGetBitsPerComponent(image.CGImage!), 0,
            CGImageGetColorSpace(image.CGImage!)!,
            CGImageGetBitmapInfo(image.CGImage!).rawValue)!;
        CGContextConcatCTM(ctx, imageTransform);
        switch (imageOrientation) {
        case .Left:
            fallthrough
        case .LeftMirrored:
            fallthrough
        case .Right:
            fallthrough
        case .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,imageSize.height,imageSize.width), image.CGImage!);
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,imageSize.width,imageSize.height), image.CGImage!);
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
