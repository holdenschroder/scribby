//
//  LibraryItemController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-16.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit

class LibraryItemController:UIViewController {
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    private var lastImage:UIImage?
    var _mAtlasGlyph: FontAtlasGlyph?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\("Edit:") \(_mAtlasGlyph!.mapping.uppercaseString)"
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
