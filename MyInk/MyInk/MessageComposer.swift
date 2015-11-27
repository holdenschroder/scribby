//
//  MessageComposer.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-26.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import MessageUI

let textMessageRecipients = ["1-604-649-3832"] 
class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = "Hey friend - Just sending a text message in-app using Swift!"
        return messageComposeVC
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        print("Result: ", result)
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}