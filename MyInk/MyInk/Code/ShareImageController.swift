//
//  ShareImageController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import Social

class ShareImageController: UIViewController, UIAlertViewDelegate {
    @IBOutlet var imageView:UIImageView?
    let FlurryEvent_ShareMessage = "Share Message"
    let FlurryEvent_ShareMessage_Parameter_Activity = "Activity"
    private var _image:UIImage?
    private var _documentController:UIDocumentInteractionController!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView?.image = _image
        
        MyInkAnalytics.TrackEvent("Screen Loaded - Share Image")
    }
    
    func loadImage(image:UIImage) {
        _image = image
        imageView?.image = image
    }
    
    @IBAction func HandleActionBtn(sender: AnyObject) {
        if _image != nil {
            let activityView = UIActivityViewController(activityItems: [_image!], applicationActivities: nil)
            activityView.completionWithItemsHandler = HandleActivityViewCompleted
            presentViewController(activityView, animated: true, completion: nil)
        }
    }
    
    @IBAction func ShareToInstagram(sender:UIBarButtonItem) {
        //This should work but does not seem to
        /*let url = NSURL(fileURLWithPath: "instagram://app")
        if(!UIApplication.sharedApplication().canOpenURL(url!)) {
            let alert = UIAlertView(title: "Instagram Not Installed", message: "The Instagram App must be installed to share with Instagram.", delegate: self, cancelButtonTitle: "Okay")
            alert.show()
            return
        }*/
        
        //Resize image to 640x640
        let instagramSize = CGSize(width: 640, height: 640)
        UIGraphicsBeginImageContext(instagramSize)
        let graphicsContext = UIGraphicsGetCurrentContext()
        UIColor.whiteColor().setFill()
        CGContextFillRect(graphicsContext, CGRect(origin: CGPointZero, size: instagramSize))
        if _image?.size.width > _image?.size.height {
            let ratioAdjustment = _image!.size.height / _image!.size.width
            _image?.drawInRect(CGRectMake(0, instagramSize.height * ((1 - ratioAdjustment) * 0.5), instagramSize.width, instagramSize.width * ratioAdjustment))
        }
        else {
            let ratioAdjustment = _image!.size.height / _image!.size.width
            _image?.drawInRect(CGRectMake(instagramSize.width * ((1 - ratioAdjustment) * 0.5), 0, instagramSize.height * ratioAdjustment, instagramSize.height))
        }
        
        let instagramImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save the image
        var filePathURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
        filePathURL = filePathURL.URLByAppendingPathComponent("instagram.igo")
        let imageData = UIImageJPEGRepresentation(instagramImage, 100)
        if(imageData!.writeToFile(filePathURL.path!, atomically: true)) {
            print("\(filePathURL) Instagram Image Saved Successfully!")
            _documentController = UIDocumentInteractionController(URL: filePathURL)
            _documentController.UTI = "com.instagram.exclusivegram"
            if(_documentController.presentOpenInMenuFromBarButtonItem(sender, animated: true) == false) {
                //Instagram is not installed, probably. Apparently Slack and Messenger can try and fail to share this filetype as well.
                let alert = UIAlertView(title: "Instagram Not Installed", message: "The Instagram App must be installed to share with Instagram.", delegate: self, cancelButtonTitle: "Okay")
                alert.show()
            }
        }
        else
        {
            print("\(filePathURL) Instagram Image FAILED to Save.")
        }
    }
    
    @IBAction func ShareToTwitter(sender:UIBarButtonItem) {
        let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composer.addImage(_image)
        self.presentViewController(composer, animated: true, completion: nil)
        MyInkAnalytics.TrackEvent(FlurryEvent_ShareMessage, parameters: [FlurryEvent_ShareMessage_Parameter_Activity:"button.twitter"])
    }
    
    func HandleActivityViewCompleted(activityType:String?, completed:Bool, items:[AnyObject]?, error:NSError?) {
        if completed {
            MyInkAnalytics.TrackEvent(FlurryEvent_ShareMessage, parameters: [FlurryEvent_ShareMessage_Parameter_Activity:activityType ?? "UnknownActivity"])
        }
        else if error != nil
        {
            Flurry.logError(FlurryEvent_ShareMessage, message: "Error while using UIActivityViewController", error: error)
        }
    }
}
