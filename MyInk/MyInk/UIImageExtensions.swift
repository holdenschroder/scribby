//
//  UIImageExtensions.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-22.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

extension UIImage {
    public func Resize(_ size:CGSize, completionHandler:@escaping (_ outputImage:UIImage, _ data:Data)->Void)
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            var imageRect:CGRect?
            if(self.size.width < self.size.height) {
                let aspectRatio = self.size.width / self.size.height
                let imageWidth = aspectRatio * size.width
                imageRect = CGRect(x: (size.width - imageWidth) * 0.5, y: 0, width: imageWidth, height: size.height)
            }
            else
            {
                let aspectRatio = self.size.height / self.size.width
                let imageHeight = aspectRatio * size.height
                imageRect = CGRect(x: 0, y: (size.height - imageHeight) * 0.5, width: size.width, height: imageHeight)
            }
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            self.draw(in: imageRect!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImagePNGRepresentation(newImage!)
            completionHandler(newImage!, imageData!)
        })
    }
    
    /**
        Return a rect representing an area of the image with high enough alpha values
        @param withinCoords a CGRect representing the area that should be searched
    */
    public func FindContentArea(_ withinCoords:CGRect) -> CGRect {
        var image_ci:UIKit.CIImage!
        if self.ciImage != nil {
            image_ci = self.ciImage!
        }
        else {
            image_ci = UIKit.CIImage(cgImage: self.cgImage!)
        }
        let rect = image_ci.extent
        let pixelBounds = withinCoords * rect.size
        
        let width = Int(floor(rect.width))
        let firstPixel = Int(floor(pixelBounds.origin.x)) + (Int(floor(pixelBounds.origin.y)) * width)
        let lastPixel = firstPixel + Int(floor(pixelBounds.width * pixelBounds.height))
        
        let componentsPerPixel = 4
        let allocationSize = componentsPerPixel * Int(rect.width * rect.height)
        let rawData: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: allocationSize)
        let context = CIContext(options: nil)
        context.render(image_ci, toBitmap: rawData, rowBytes: componentsPerPixel * width, bounds: rect, format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        
        var topLeft = CGPoint(x: pixelBounds.size.width, y: pixelBounds.size.height)
        var bottomRight = CGPoint.zero
        
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
        
        rawData.deinitialize()
        rawData.deallocate(capacity: allocationSize)
        
        let rectSize = CGSize(width: bottomRight.x - topLeft.x, height: floor(bottomRight.y - topLeft.y))
        var bounds = CGRect(x: topLeft.x, y: topLeft.y, width: rectSize.width, height: rectSize.height)
        bounds = bounds / rect.size
        
        return bounds
    }
    
    public func CropImage(_ rect:CGRect) -> UIImage {
        let imageRef = self.cgImage!.cropping(to: rect)
        return UIImage(cgImage: imageRef!)
    }
}
