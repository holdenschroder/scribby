//
//  ShareImageController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import Social
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ShareImageController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var instagramBtn: UIBarButtonItem!
    @IBOutlet weak var twitterBtn: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView!
    fileprivate var _image: UIImage?
    fileprivate var _documentController:UIDocumentInteractionController!
    var audioHelper = AudioHelper()
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        imageView?.image = _image
        
        let igImg : UIImage? = UIImage(named:"icon_instagram.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let igBtn = UIButton()
        igBtn.setImage(igImg, for: UIControlState())
        igBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //igBtn.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
        let _instagramBtn = UIBarButtonItem(customView: igBtn)
        instagramBtn = _instagramBtn
        //instagramBtn.setBackButtonBackgroundImage(UIImage(named:"icon_instagram.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal, barMetrics: .Default)
        //let twImg : UIImage? = UIImage(named:"icon_twitter.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        twitterBtn.setBackButtonBackgroundImage(UIImage(named:"icon_twitter.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState(), barMetrics: .default)
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedShareImage)

        setUpScrollView()
    }
    
    func loadImage(_ image:UIImage) {
        _image = image
        imageView?.image = image
    }
    
    @IBAction func HandleActionBtn(_ sender: AnyObject) {
        if _image != nil {
            let activityView = UIActivityViewController(activityItems: [_image!], applicationActivities: nil)
            activityView.completionWithItemsHandler = handleActivityViewCompleted()
            present(activityView, animated: true, completion: nil)
        }
    }

    fileprivate func setUpScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.contentSize = imageView.bounds.size
    }
    
    @IBAction func ShareToInstagram(_ sender:UIBarButtonItem) {
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
        UIColor.white.setFill()
        graphicsContext!.fill(CGRect(origin: CGPoint.zero, size: instagramSize))
        if _image?.size.width > _image?.size.height {
            let ratioAdjustment = _image!.size.height / _image!.size.width
            _image?.draw(in: CGRect(x: 0, y: instagramSize.height * ((1 - ratioAdjustment) * 0.5), width: instagramSize.width, height: instagramSize.width * ratioAdjustment))
        }
        else {
            let ratioAdjustment = _image!.size.height / _image!.size.width
            _image?.draw(in: CGRect(x: instagramSize.width * ((1 - ratioAdjustment) * 0.5), y: 0, width: instagramSize.height * ratioAdjustment, height: instagramSize.height))
        }
        
        let instagramImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save the image
        var filePathURL = URL(fileURLWithPath: NSTemporaryDirectory())
        filePathURL = filePathURL.appendingPathComponent("instagram.igo")
        let imageData = UIImageJPEGRepresentation(instagramImage!, 100)
        if((try? imageData!.write(to: URL(fileURLWithPath: filePathURL.path), options: [.atomic])) != nil) {
            print("\(filePathURL) Instagram Image Saved Successfully!")
            _documentController = UIDocumentInteractionController(url: filePathURL)
            _documentController.uti = "com.instagram.exclusivegram"
            if(_documentController.presentOpenInMenu(from: sender, animated: true) == false) {
                let alert = UIAlertController(title: "Instagram Not Installed", message: "The Instagram App must be installed to share with Instagram.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            else {
                audioHelper.playSentSound()
                MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity:"button.instagram"])
            }
        }
        else
        {
            print("\(filePathURL) Instagram Image FAILED to Save.")
            let error = NSError(domain: "Memory Warning", code: 0, userInfo: nil)
            Flurry.logError(SharedMyInkValues.kEventShareMessage, message: "Error while saving Instagram photo", error: error)
        }
    }
    
    @IBAction func ShareToTwitter(_ sender:UIBarButtonItem) {
        let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composer?.add(_image)
        self.present(composer!, animated: true, completion: completionHandler)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity:"button.twitter"])
    }
    
    func completionHandler() {
        audioHelper.playSentSound()
    }

    func handleActivityViewCompleted() -> ((UIActivityType?, Bool, [Any]?, Error?) -> Void) {

//    func handleActivityViewCompleted() -> ((UIActivityType?, Bool, NSArray?, NSError?) -> ()) {
        return {
            activityType, completed, returnedItems, error in

//        }
//
//    func HandleActivityViewCompleted(_ activityType:String?, completed:Bool, items:[AnyObject]?, error:NSError?) {
            if completed {
                self.audioHelper.playSentSound()
                MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventShareMessage, parameters: [SharedMyInkValues.kEventShareMessageParameterActivity: activityType?.rawValue ?? "UnknownActivity"])
            }
            else if error != nil
            {
                Flurry.logError(SharedMyInkValues.kEventShareMessage, message: "Error while using UIActivityViewController", error: error)
            }
        }
    }
}

extension ShareImageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
