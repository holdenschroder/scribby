//
//  ExampleController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-25.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


class ExampleController: UIViewController, UIAlertViewDelegate {
    
    private var _image:UIImage?
    @IBOutlet var imageView:UIImageView?
    
    
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var xBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.image = _image
        
        redoBtn.layer.cornerRadius = 3.0
        redoBtn.layer.borderWidth = 1.0
        redoBtn.layer.borderColor = UIColor.whiteColor().CGColor
        redoBtn.layer.masksToBounds = true
        
        shareBtn.layer.cornerRadius = 3.0
        shareBtn.layer.borderWidth = 1.0
        shareBtn.layer.borderColor = UIColor.whiteColor().CGColor
        shareBtn.layer.masksToBounds = true
        
        createBtn.layer.cornerRadius = 3.0
        createBtn.layer.borderWidth = 1.0
        createBtn.layer.borderColor = UIColor.whiteColor().CGColor
        createBtn.layer.masksToBounds = true
        
        xBtn.layer.cornerRadius = 3.0
        xBtn.layer.borderWidth = 1.0
        xBtn.layer.borderColor = UIColor.whiteColor().CGColor
        xBtn.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
 
    }
    

    
    // MARK: - Misc Methods
    
    func shareRequested() {
        /*
        if _image != nil {
            let activityView = UIActivityViewController(activityItems: [_image!], applicationActivities: nil)
            activityView.completionWithItemsHandler = HandleActivityViewCompleted
            presentViewController(activityView, animated: true, completion: nil)
        }
        */
        let messageComposer = MessageComposer()
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            // Note that the dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }

    func HandleActivityViewCompleted(activityType:String?, completed:Bool, items:[AnyObject]?, error:NSError?) {
        if completed {
            
        }
    }

    
    // MARK: - Delegate Methods
    

    
    // MARK: - Actions
    
    func loadImage(image:UIImage) {
        _image = image
        imageView?.image = image
    }
    
    @IBAction func redoAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        let alert = UIAlertController(title: "Share", message: "Why don't you send it to yourself? \n(then you can see what it looks like!)", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Share Cancelled")
        }
        alert.addAction(cancelAction)
        let ShareAction = UIAlertAction(title: "Share", style: .Default) { (action) in
            self.shareRequested()
        }
        alert.addAction(ShareAction)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    @IBAction func createAction(sender: AnyObject) {
        presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TutorialPhrase") as UIViewController, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainMenu") as UIViewController, animated: true, completion: nil)
    }
    
}

