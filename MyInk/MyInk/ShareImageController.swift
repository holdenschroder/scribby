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
    
    @IBOutlet weak var instagramBtn: UIBarButtonItem!
    @IBOutlet weak var twitterBtn: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView!
    private var _image: UIImage?
    private var _documentController:UIDocumentInteractionController!
    var audioHelper = AudioHelper()
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        imageView?.image = _image
        
        let igImg : UIImage? = UIImage(named:"icon_instagram.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let igBtn = UIButton()
        igBtn.setImage(igImg, forState: .Normal)
        igBtn.frame = CGRectMake(0, 0, 30, 30)
        //igBtn.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
        let _instagramBtn = UIBarButtonItem(customView: igBtn)
        instagramBtn = _instagramBtn
        //instagramBtn.setBackButtonBackgroundImage(UIImage(named:"icon_instagram.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal, barMetrics: .Default)
        //let twImg : UIImage? = UIImage(named:"icon_twitter.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        twitterBtn.setBackButtonBackgroundImage(UIImage(named:"icon_twitter.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal, barMetrics: .Default)
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedShareImage)

        setUpScrollView()
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

    private func setUpScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.contentSize = imageView.bounds.size
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
        CGContextFillRect(graphicsContext!, CGRect(origin: CGPointZero, size: instagramSize))
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
        filePathURL = filePathURL.URLByAppendingPathComponent("instagram.igo")!
        let imageData = UIImageJPEGRepresentation(instagramImage!, 100)
        if(imageData!.writeToFile(filePathURL.path!, atomically: true)) {
            print("\(filePathURL) Instagram Image Saved Successfully!")
            _documentController = UIDocumentInteractionController(URL: filePathURL)
            _documentController.UTI = "com.instagram.exclusivegram"
            if(_documentController.presentOpenInMenuFromBarButtonItem(sender, animated: true) == false) {
                let alert = UIAlertView(title: "Instagram Not Installed", message: "The Instagram App must be installed to share with Instagram.", delegate: self, cancelButtonTitle: "Okay")
                alert.show()
            }
            else {
                audioHelper.playSentSound()
                MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity:"button.instagram"])
            }
        }
        else
        {
            print("\(filePathURL) Instagram Image FAILED to Save.")
            let error = NSError?()
            Flurry.logError(SharedMyInkValues.kEventShareMessage, message: "Error while saving Instagram photo", error: error)
        }
    }
    
    @IBAction func ShareToTwitter(sender:UIBarButtonItem) {
        let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composer.addImage(_image)
        self.presentViewController(composer, animated: true, completion: completionHandler)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity:"button.twitter"])
    }
    
    func completionHandler() {
        audioHelper.playSentSound()
    }
    
    func HandleActivityViewCompleted(activityType:String?, completed:Bool, items:[AnyObject]?, error:NSError?) {
        if completed {
            audioHelper.playSentSound()
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity:activityType ?? "UnknownActivity"])
        }
        else if error != nil
        {
            Flurry.logError(SharedMyInkValues.kEventShareMessage, message: "Error while using UIActivityViewController", error: error)
        }
    }
}

extension ShareImageController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
