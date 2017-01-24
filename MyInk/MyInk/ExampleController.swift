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
    
    fileprivate var _image:UIImage?
    fileprivate var messageVC:MFMessageComposeViewController!
    fileprivate var mailVC:MFMailComposeViewController!
    var audioHelper = AudioHelper()
    
    @IBOutlet var imageView:UIImageView?
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageVC = MFMessageComposeViewController()
        mailVC = MFMailComposeViewController()
        
        audioHelper.playYeahSound()
        
        imageView?.image = _image
        
        redoBtn.layer.cornerRadius = 6.0
        redoBtn.layer.borderWidth = 2.0
        redoBtn.layer.borderColor = UIColor.white.cgColor
        redoBtn.layer.masksToBounds = true
        
        shareBtn.layer.cornerRadius = 6.0
        shareBtn.layer.borderWidth = 2.0
        shareBtn.layer.borderColor = UIColor.white.cgColor
        shareBtn.layer.masksToBounds = true
        
        createBtn.layer.cornerRadius = 6.0
        createBtn.layer.borderWidth = 2.0
        createBtn.layer.borderColor = UIColor.white.cgColor
        createBtn.layer.masksToBounds = true
    }


    
    // MARK: - Misc Methods
    
    func shareEmail() {
        if(MFMailComposeViewController.canSendMail()) {
            mailVC.mailComposeDelegate = self;
            mailVC .setSubject("MyInk")
            mailVC.setMessageBody("You're So Pretty", isHTML: true)
            let data: Data = UIImagePNGRepresentation(_image!)!
            mailVC.addAttachmentData(data, mimeType: "image/jpg", fileName: "image.jpg")
            self.present(mailVC, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Cannot Send Email", message: "Your device is not configured to send email.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func shareMessage() {
        if(MFMessageComposeViewController.canSendText()) {
            messageVC.body = "You're So Pretty";
            messageVC.addAttachmentData(UIImageJPEGRepresentation(_image!, 1)!, typeIdentifier: "image/jpg", filename: "image.jpg")
            messageVC.messageComposeDelegate = self;
            self.present(messageVC, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Delegate Methods
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message Cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message Failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message Sent")
            self.dismiss(animated: true, completion: {
                self.audioHelper.playSentSound()
                self.closeScreen()
            })
        default:
            break;
        }
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Email Cancelled")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved.rawValue:
            print("Email Saved")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            print("Email Sent")
            self.dismiss(animated: true, completion: {
                self.audioHelper.playSentSound()
                self.closeScreen()
            })
        case MFMailComposeResult.failed.rawValue:
            print("Email Failed")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }

    
    // MARK: - Actions
    
    func closeScreen() {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            UserDefaults.standard.set(true, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationRoot") as UIViewController, animated: true, completion: nil)
        })
    }
    
    func loadImage(_ image:UIImage) {
        _image = image
        imageView?.image = image
    }
    
    @IBAction func redoAction(_ sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareAction(_ sender: AnyObject) {
        let options = UIAlertController(title: nil, message: "Choose Option: \nHint: Try sending it to yourself... \nThen you can see what it looks like!", preferredStyle: .actionSheet)
        let messageAction = UIAlertAction(title: "iMessage", style: .default) { (action) in
            self.shareMessage()
        }
        let mailAction = UIAlertAction(title: "Email", style: .default) { (action) in
            self.shareEmail()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            print("Share Cancelled")
        }
        options.addAction(messageAction)
        options.addAction(mailAction)
        options.addAction(cancelAction)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.present(options, animated: true, completion: nil)
        })
    }

    @IBAction func createAction(_ sender: AnyObject) {
        audioHelper.playAwesomeSound()
        present(UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "TutorialIntro") as UIViewController, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        closeScreen()
    }
    
}

