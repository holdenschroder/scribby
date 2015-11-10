//
//  UIImageExtensions.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

extension UIImage {
    public func Resize(size:CGSize, completionHandler:(outputImage:UIImage, data:NSData)->Void)
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            var imageRect:CGRect?
            if(self.size.width < self.size.height) {
                let aspectRatio = self.size.width / self.size.height
                let imageWidth = aspectRatio * size.width
                imageRect = CGRectMake((size.width - imageWidth) * 0.5, 0, imageWidth, size.height)
            }
            else
            {
                let aspectRatio = self.size.height / self.size.width
                let imageHeight = aspectRatio * size.height
                imageRect = CGRectMake(0, (size.height - imageHeight) * 0.5, size.width, imageHeight)
            }
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            self.drawInRect(imageRect!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImagePNGRepresentation(newImage)
            completionHandler(outputImage: newImage, data: imageData!)
        })
    }
    
    /**
        Return a rect representing an area of the image with high enough alpha values
        @param withinCoords a CGRect representing the area that should be searched
    */
    public func FindContentArea(withinCoords:CGRect) -> CGRect {
        var image_ci:UIKit.CIImage!
        if self.CIImage != nil {
            image_ci = self.CIImage!
        }
        else {
            image_ci = UIKit.CIImage(CGImage: self.CGImage!)
        }
        let rect = image_ci.extent
        let pixelBounds = withinCoords * rect.size
        
        let width = Int(floor(rect.width))
        let firstPixel = Int(floor(pixelBounds.origin.x)) + (Int(floor(pixelBounds.origin.y)) * width)
        let lastPixel = firstPixel + Int(floor(pixelBounds.width * pixelBounds.height))
        
        let componentsPerPixel = 4
        let allocationSize = componentsPerPixel * Int(rect.width * rect.height)
        let rawData: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.alloc(allocationSize)
        let context = CIContext(options: nil)
        context.render(image_ci, toBitmap: rawData, rowBytes: componentsPerPixel * width, bounds: rect, format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        
        var topLeft = CGPoint(x: pixelBounds.size.width, y: pixelBounds.size.height)
        var bottomRight = CGPointZero
        
        for index in firstPixel..<lastPixel {
            let pixelInfo: Int = index * componentsPerPixel
            
            let a = rawData[pixelInfo+3]
            if(a > 55)
            {
                let pixelPos = CGPoint(x: index % width, y: index / width)
                if(pixelPos.x < topLeft.x) {
                    topLeft.x = pixelPos.x
                }
                if(pixelPos.x > bottomRight.x) {
                    bottomRight.x = pixelPos.x
                }
                
                if(pixelPos.y < topLeft.y) {
                    topLeft.y = pixelPos.y
                }
                if(pixelPos.y > bottomRight.y) {
                    bottomRight.y = pixelPos.y
                }
            }
        }
        
        rawData.destroy()
        rawData.dealloc(allocationSize)
        
        let rectSize = CGSize(width: bottomRight.x - topLeft.x, height: floor(bottomRight.y - topLeft.y))
        var bounds = CGRect(x: topLeft.x, y: topLeft.y, width: rectSize.width, height: rectSize.height)
        bounds = bounds / rect.size
        
        return bounds
    }
    
    public func CropImage(rect:CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, rect)
        return UIImage(CGImage: imageRef!)
    }
}