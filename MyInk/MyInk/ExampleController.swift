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
import MessageUI    


class ExampleController: UIViewController, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    private var _image:UIImage?
    private var messageVC:MFMessageComposeViewController!
    private var mailVC:MFMailComposeViewController!
    
    @IBOutlet var imageView:UIImageView?
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var xBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageVC = MFMessageComposeViewController()
        mailVC = MFMailComposeViewController()
        
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
    
    func shareEmail() {
        if(MFMailComposeViewController.canSendMail()) {
            mailVC.mailComposeDelegate = self;
            mailVC .setSubject("MyInk Test")
            mailVC.setMessageBody("You're So Pretty", isHTML: true)
            let data: NSData = UIImagePNGRepresentation(_image!)!
            mailVC.addAttachmentData(data, mimeType: "image/jpg", fileName: "image.jpg")
            self.presentViewController(mailVC, animated: true, completion: nil)
        }
        else {
            let errorAlert = UIAlertView(title: "Cannot Send Email", message: "Your device is not configured to send email.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    func shareMessage() {
        messageVC.body = "You're So Pretty";
        messageVC.addAttachmentData(UIImageJPEGRepresentation(_image!, 1)!, typeIdentifier: "image/jpg", filename: "image.jpg")
        messageVC.recipients = ["1-604-649-3832"]
        messageVC.messageComposeDelegate = self;
        if(MFMessageComposeViewController.canSendText()) {
            self.presentViewController(messageVC, animated: true, completion: nil)
        }
        else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }

    
    // MARK: - Delegate Methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message Cancelled")
        case MessageComposeResultFailed.rawValue:
            print("Message Failed")
        case MessageComposeResultSent.rawValue:
            print("Message Sent")
        default:
            break;
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Email Cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Email Saved")
        case MFMailComposeResultSent.rawValue:
            print("Email Sent")
        case MFMailComposeResultFailed.rawValue:
            print("Email Failed")
        default:
            break;
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Actions
    
    func loadImage(image:UIImage) {
        _image = image
        imageView?.image = image
    }
    
    @IBAction func redoAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        let options = UIAlertController(title: nil, message: "Choose Option: \nHint: Try sending it to yourself... \nThen you can see what it looks like!", preferredStyle: .ActionSheet)
        let messageAction = UIAlertAction(title: "iMessage", style: .Default) { (action) in
            self.shareMessage()
        }
        let mailAction = UIAlertAction(title: "Email", style: .Default) { (action) in
            self.shareEmail()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
            print("Share Cancelled")
        }
        options.addAction(messageAction)
        options.addAction(mailAction)
        options.addAction(cancelAction)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(options, animated: true, completion: nil)
        })
    }

    @IBAction func createAction(sender: AnyObject) {
        presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TutorialPhrase") as UIViewController, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainMenu") as UIViewController, animated: true, completion: nil)
    }
    
}

