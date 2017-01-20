//
//  LibraryItemController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-16.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit

class LibraryItemController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: VARS
    
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    @IBOutlet weak var characterLabel: UILabel!
    
    fileprivate var lastImage:UIImage?
    var _mAtlasGlyph: FontAtlasGlyph?
    var captureView:CaptureWordSelectController!
    

    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\("Edit:") \(_mAtlasGlyph!.mapping)"
        self.characterLabel.text = _mAtlasGlyph!.mapping
        UIView.animate(withDuration: 0.5, animations: {
            self.characterLabel?.alpha = 0.05
        })
        
        //let camButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "openCapture")
        //navigationItem.rightBarButtonItem = camButton
        
        captureView = storyboard?.instantiateViewController(withIdentifier: "CaptureView") as? CaptureWordSelectController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    

    
    // MARK: CAPTURE
    
    func showCaptureView(_ image:UIImage) {
        self.captureView.loadImage(image)
        self.captureView._mAtlasGlyph = _mAtlasGlyph
        self.show(self.captureView, sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        let imageSize = image.size
        var imageTransform:CGAffineTransform = CGAffineTransform.identity
        //Build a transform to offset and rotate the rect depending on the orientation
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.downMirrored:
            fallthrough
        case UIImageOrientation.down:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: imageSize.height)
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI))
        case UIImageOrientation.leftMirrored:
            fallthrough
        case UIImageOrientation.left:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: 0)
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI_2))
        case UIImageOrientation.rightMirrored:
            fallthrough
        case UIImageOrientation.right:
            imageTransform = imageTransform.translatedBy(x: 0, y: imageSize.height)
            imageTransform = imageTransform.rotated(by: CGFloat(-M_PI_2))
        default:
            break
        }
        
        //Compensate for Mirrored orientations
        switch(imageOrientation)
        {
        case UIImageOrientation.upMirrored:
            fallthrough
        case UIImageOrientation.downMirrored:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: 0)
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.leftMirrored:
            fallthrough
        case UIImageOrientation.rightMirrored:
            imageTransform = imageTransform.translatedBy(x: imageSize.height, y: 0)
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(imageSize.width), height: Int(imageSize.height),
            bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
        ctx.concatenate(imageTransform);
        switch (imageOrientation) {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .right:
            fallthrough
        case .rightMirrored:
            ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: imageSize.height,height: imageSize.width));
            
        default:
            ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: imageSize.width,height: imageSize.height));
        }
        
        let cgimg = ctx.makeImage();
        let img = UIImage(cgImage: cgimg!)//UIImage imageWithCGImage:cgimg]
        
        picker.dismiss(animated: true, completion: nil)
        showCaptureView(img)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryPhotoTaken)
    }
    
    
    // MARK: ACTIONS
    
    func openCapture() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            DispatchQueue.main.async(execute: {
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imgPicker, animated: true, completion: nil)
            })
        }
        else //Load Test Image
        {
            showCaptureView(UIImage(named: "CapturePositioningTest")!)
        }
    }
    
    @IBAction func mapAction(_ sender: AnyObject) {
        _ = self.drawCaptureView?.save((_mAtlasGlyph?.mapping)!, captureType:"Touch")
        self.drawCaptureView?.clear()
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func clearAction(_ sender: AnyObject) {
        self.drawCaptureView?.clear()
    }
    
    
}
