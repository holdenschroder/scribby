//
//  ViewController.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-05-14.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView:UIImageView?
    @IBOutlet var drawView:UIDrawView?
    @IBOutlet var colorTest:UIView?
    @IBOutlet var debugCrosshair:UIImageView?
    @IBOutlet var toleranceSlider:UISlider?
    @IBOutlet var debugRect:UIView?
    var selectedColor:CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
    var isolationFilter:CIColorKernel?
    var toleranceValue:Float = 0.2
    private var originalImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        imageView?.userInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)
        debugCrosshair?.hidden = true
        debugRect?.hidden = true
        toleranceSlider?.setValue(toleranceValue, animated: false)
        colorTest?.backgroundColor = UIColor(CIColor: selectedColor)
        
        //Load Filter
        let filterPath = NSBundle.mainBundle().pathForResource("isolationfilter", ofType: "cikernal")
        let filterCode = String(contentsOfFile: filterPath!, encoding: NSUTF8StringEncoding, error: nil)
        isolationFilter = CIColorKernel(string: filterCode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCamera(sender: UIButton) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imgPicker, animated: true, completion: nil)
        }
        else //Load Test Image
        {
            imageView?.image = UIImage(named: "HelloTest")
            originalImage = imageView?.image!.copy() as? UIImage
        }
        
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        if(recognizer.view == imageView && imageView!.image != nil) {
            imageView!.image = originalImage
            let point = recognizer.locationInView(imageView!)
            selectedColor = GetPixelColor(imageView!, position: point)
            debugCrosshair?.hidden = false
            debugCrosshair?.frame.origin = recognizer.locationInView(imageView!.superview) - CGPoint(x: debugCrosshair!.frame.width * 0.5, y: debugCrosshair!.frame.height * 0.5)
            colorTest?.backgroundColor = UIColor(CIColor: selectedColor)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //let croppedImage = resizeImage(image, newSize: imageView!.frame.size)
        originalImage = image.copy() as? UIImage
        imageView?.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image:UIImage, newSize:CGSize) -> UIImage
    {
        var ratio:CGFloat = 0.0
        var delta:CGFloat = 0.0
        var offset = CGPoint.zeroPoint
        
        var sz = CGSizeMake(newSize.width, newSize.width);
        
        if(image.size.width > image.size.height) {
            ratio = newSize.width / image.size.width;
            delta = (ratio*image.size.width - ratio*image.size.height);
            offset = CGPointMake(delta/2, 0);
        }
        else {
            ratio = newSize.height / image.size.height;
            delta = (ratio*image.size.height - ratio*image.size.width);
            offset = CGPointMake(0, delta/2);
        }
    
        var clipRect = CGRectMake(-offset.x, -offset.y,
                (ratio * image.size.width) + delta,
                (ratio * image.size.height) + delta);
        
        UIGraphicsBeginImageContextWithOptions(sz, true, 0.0);
        UIRectClip(clipRect);
        image.resizingMode
        image.drawInRect(clipRect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    func GetPixelColor(view:UIImageView, position:CGPoint) -> CIColor {
        let image = view.image!
        var imgPos = view.convertPointFromView(position)
        var imgRect = CGRect(origin: CGPointZero, size: image.size)
        
        var imageTransform:CGAffineTransform = CGAffineTransformIdentity
        
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.DownMirrored:
            fallthrough
        case UIImageOrientation.Down:
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_4))
        case UIImageOrientation.LeftMirrored:
            fallthrough
        case UIImageOrientation.Left:
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(-M_PI_2))
        case UIImageOrientation.RightMirrored:
            fallthrough
        case UIImageOrientation.Right:
            imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
            imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_2))
            imgPos.x = imgRect.width - imgPos.x
        default:
            break
        }
        
        imgPos = CGPointApplyAffineTransform(imgPos, imageTransform)
        imgRect = CGRectApplyAffineTransform(imgRect, imageTransform)
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 1
        
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
        if(imgPos.x > -1 && imgPos.x < imgRect.width && imgPos.y > -1 && imgPos.y < imgRect.height) {
            var pixelInfo: Int = ((Int(imgRect.width) * Int(imgPos.y)) + Int(imgPos.x)) * 4
            
            r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        }
        
        return CIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func GetImagePos(view:UIImageView, viewPosition:CGPoint) -> CGPoint {
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
    
    @IBAction func ProcessImageHandler(sender: UIButton) {
        ProcessImage()
    }
    
    func ProcessImage() {
        if(originalImage != nil && isolationFilter != nil) {
            let context = CIContext(options: nil)
            let cgImage:CGImageRef = originalImage!.CGImage
            let image = CIImage(CGImage: originalImage!.CGImage)
            
            var rect = drawView!.GetContentRect()
            var debugRectDimensions = rect
            if(rect == CGRectZero) {
                rect = image!.extent()
            }
            else {
                //debugRectDimensions = imageView!.superview!.convertRect(rect, fromView: drawView)
                rect.origin.y = imageView!.frame.height - rect.origin.y - rect.height
                rect = drawView!.convertRect(rect, toView: imageView)
                rect = imageView!.convertRectFromView(rect)
            }
            
            var imageTransform:CGAffineTransform = CGAffineTransformIdentity
            
            let imageOrientation = originalImage!.imageOrientation
            switch(imageOrientation)
            {
            case UIImageOrientation.DownMirrored:
                fallthrough
            case UIImageOrientation.Down:
                imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_4))
            case UIImageOrientation.LeftMirrored:
                fallthrough
            case UIImageOrientation.Left:
                imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
                imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(-M_PI_2))
            case UIImageOrientation.RightMirrored:
                fallthrough
            case UIImageOrientation.Right:
                imageTransform = CGAffineTransformScale(imageTransform, -1, 1)
                imageTransform = CGAffineTransformRotate(imageTransform, CGFloat(M_PI_2))
            default:
                break
            }
            
            rect = CGRectApplyAffineTransform(rect, imageTransform)
            
            /*debugRect?.frame.origin = debugRectDimensions.origin
            debugRect?.frame.size = debugRectDimensions.size
            debugRect?.hidden = false*/
            
            selectedColor = FindInkColor(originalImage!, dimensions: rect)
            
            let outputImage = isolationFilter?.applyWithExtent(rect, roiCallback: ROICallback, arguments: [image, selectedColor, CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), toleranceValue])
            let imageRef = context.createCGImage(outputImage, fromRect: rect)
            let originalOrientation = imageView!.image!.imageOrientation
            let originalScale = imageView!.image!.scale
            let newImage = UIImage(CGImage: imageRef, scale: originalScale, orientation: originalOrientation)
            imageView?.image = newImage
            
            drawView?.hidden = true
        }
    }
    
    private func ROICallback(index:Int32, rect:CGRect) -> CGRect
    {
        return rect;
    }
    
    @IBAction func ToleranceValueChanged(sender: UISlider) {
        toleranceValue = sender.value
    }
    
    private func FindInkColor(image:UIImage, dimensions:CGRect) -> CIColor {
        let imageRef = image.CGImage
        let width = Int(dimensions.width)
        let height = Int(dimensions.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8;
        var rawData:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(width * height * bytesPerPixel)
        
        let context = CGBitmapContextCreate(rawData, width, height,
            bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
        
        CGContextDrawImage(context, CGRect(x: dimensions.origin.x, y: dimensions.origin.y, width: CGFloat(width), height: CGFloat(height)), imageRef)
        
        var color = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        var lowestLuminance:CGFloat = 1.0
        
        for index in 0..<Int(width * height) {
            var pixelInfo: Int = index * bytesPerPixel
            let r = CGFloat(rawData[pixelInfo]) / 255
            let g = CGFloat(rawData[pixelInfo+1]) / 255
            let b = CGFloat(rawData[pixelInfo+2]) / 255
            let a = CGFloat(rawData[pixelInfo+3]) / 255
            let luminance = (r * 0.299) + (g * 0.587) + (b * 0.114)
            if(luminance < lowestLuminance) {
                lowestLuminance = luminance
                color = CIColor(red: r, green: g, blue: b, alpha: a)
            }
        }
        return color
    }
}

