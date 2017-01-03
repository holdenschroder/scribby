//
//  CaptureWordSelectView.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-05-14.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

class CaptureWordSelectController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView:UIImageView?
    @IBOutlet var selectionView:UIDrawSelectionView?
    @IBOutlet var colorTest:UIView?
    @IBOutlet var debugCrosshair:UIImageView?
    @IBOutlet var toleranceSlider:UISlider?
    @IBOutlet var debugRect:UIView?
    @IBOutlet var selectBtn:UIBarButtonItem?
    
    fileprivate var cameraImage:UIImage?
    fileprivate var inkColour:CIColor?
    var _mAtlasGlyph: FontAtlasGlyph?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)
        debugCrosshair?.isHidden = true
        debugRect?.isHidden = true
        selectBtn?.isEnabled = false
        
        imageView?.image = cameraImage
        selectionView!.addOnChangeListener(handleSelectionChange)
        
        if(cameraImage != nil) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                self.inkColour = ImageCropUtility.FindInkColor(self.cameraImage!)
            })
        }
    }
    
    func loadImage(_ image:UIImage) {
        cameraImage = image
        imageView?.image = cameraImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        selectionView?.clearImage()
        selectBtn?.isEnabled = false
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureWordSelect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let error = NSError(domain: "Memory Warning", code: 0, userInfo: nil)
        print(error)
        Flurry.logError(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect, message: "Memory Warning", error: error)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if self.isMovingFromParentViewController {
            cameraImage = nil
            imageView?.image = nil
            selectionView?.clearImage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is CaptureCharacterSelectController {
            let processView = segue.destination as! CaptureCharacterSelectController
            if((_mAtlasGlyph) != nil) {
                processView._mAtlasGlyph = _mAtlasGlyph
            }
            let cropImage = selectionView!.CropImageBySelection(imageView!)
            if(cropImage != nil) {
                processView.LoadImage(cropImage!, inkColor: inkColour)
            }
        }
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
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
            imageView?.image = UIImage(named: "YopTest")
            selectBtn?.isEnabled = true
        }
        
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

        var transformedImage = CIImage(cgImage: image.cgImage!)
        transformedImage = transformedImage.applying(imageTransform)
        imageView?.image = UIImage(ciImage: transformedImage)
        picker.dismiss(animated: true, completion: nil)
        selectBtn?.isEnabled = true
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCapturePhotoTaken)
    }

    func resizeImage(_ image:UIImage, newSize:CGSize) -> UIImage
    {
        var ratio:CGFloat = 0.0
        var delta:CGFloat = 0.0
        var offset = CGPoint.zero

        let sz = CGSize(width: newSize.width, height: newSize.width);
        
        if(image.size.width > image.size.height) {
            ratio = newSize.width / image.size.width;
            delta = (ratio*image.size.width - ratio*image.size.height);
            offset = CGPoint(x: delta/2, y: 0);
        }
        else {
            ratio = newSize.height / image.size.height;
            delta = (ratio*image.size.height - ratio*image.size.width);
            offset = CGPoint(x: 0, y: delta/2);
        }
    
        let clipRect = CGRect(x: -offset.x, y: -offset.y,
                width: (ratio * image.size.width) + delta,
                height: (ratio * image.size.height) + delta);
        
        UIGraphicsBeginImageContextWithOptions(sz, true, 0.0);
        UIRectClip(clipRect);
        image.resizingMode
        image.draw(in: clipRect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    func GetPixelColor(_ view:UIImageView, position:CGPoint) -> CIColor {
        let image = view.image!
        var imgPos = view.convertPoint(fromView: position)
        var imgRect = CGRect(origin: CGPoint.zero, size: image.size)
        
        var imageTransform:CGAffineTransform = CGAffineTransform.identity
        
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.downMirrored:
            fallthrough
        case UIImageOrientation.down:
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI_4))
        case UIImageOrientation.leftMirrored:
            fallthrough
        case UIImageOrientation.left:
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
            imageTransform = imageTransform.rotated(by: CGFloat(-M_PI_2))
        case UIImageOrientation.rightMirrored:
            fallthrough
        case UIImageOrientation.right:
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI_2))
            imgPos.x = imgRect.width - imgPos.x
        default:
            break
        }
        
        imgPos = imgPos.applying(imageTransform)
        imgRect = imgRect.applying(imageTransform)
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 1
        
        let pixelData = image.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
        if(imgPos.x > -1 && imgPos.x < imgRect.width && imgPos.y > -1 && imgPos.y < imgRect.height) {
            let pixelInfo: Int = ((Int(imgRect.width) * Int(imgPos.y)) + Int(imgPos.x)) * 4
            
            r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        }
        
        return CIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func GetImagePos(_ view:UIImageView, viewPosition:CGPoint) -> CGPoint {
        let image = view.image!
        let imgSize = image.size
        let viewSize = view.bounds.size
        
        let ratioX = viewSize.width / imgSize.width
        let ratioY = viewSize.height / imgSize.height
        let scale = min(ratioX, ratioY)
        
        var finalPos = viewPosition
        finalPos.x -= (viewSize.width - imgSize.width * scale) / 2.0
        finalPos.y -= (viewSize.height - imgSize.height * scale) / 2.0
        
        finalPos.x /= scale
        finalPos.y /= scale
        
        return finalPos
    }
    
    func handleSelectionChange(_ selectionView:UIDrawSelectionView, cleared:Bool) -> Void {
        selectBtn?.isEnabled = !cleared
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

