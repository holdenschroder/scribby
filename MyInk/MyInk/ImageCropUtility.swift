//
//  ImageCropUtility.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-07-03.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class ImageCropUtility
{
    static func CropImageToAlpha(image:UIImage) -> UIImage {
        let image_ci = image.CIImage != nil ? image.CIImage! : CIImage(CGImage: image.CGImage!)
        var rect = image_ci.extent
        
        let width = Int(rect.width)
        let firstPixel = 0
        let lastPixel = Int(floor(rect.width * rect.height))
        
        let bytesPerPixel = 4
        let rawData: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.alloc(bytesPerPixel * lastPixel)
        let context = CIContext(options: [kCIContextUseSoftwareRenderer : true])
        context.render(image_ci, toBitmap: rawData, rowBytes: bytesPerPixel * Int(floor(rect.width)), bounds: rect, format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        var topLeft = CGPoint(x: image.size.width, y: image.size.height)
        var bottomRight = CGPoint(x: 0, y: 0)
        
        for index in firstPixel..<lastPixel {
            let pixelInfo: Int = index * bytesPerPixel
            
            let a = rawData[pixelInfo+3]
            if(a > 5)
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
        
        let rectSize = CGSize(width: bottomRight.x - topLeft.x, height: floor(bottomRight.y - topLeft.y))
        rect = CGRect(x: floor(topLeft.x), y: floor(rect.height - topLeft.y - rectSize.height), width: rectSize.width, height: rectSize.height)
        
        let croppedImage = image_ci.imageByCroppingToRect(rect)
        let transform = CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y)
        let transformedImage = croppedImage.imageByApplyingTransform(transform)
        
        return UIImage(CIImage: transformedImage)
    }
    
    static func FindInkColor(image:UIImage) -> CIColor {
        if image.CGImage != nil {
            return FindInkColor(image.CGImage!)
        }
        else {
            return FindInkColor(image.CIImage!)
        }
    }
    
    static func FindInkColor(image:CIImage) -> CIColor {
        let context = CIContext(options: [kCIContextUseSoftwareRenderer : true])
        let cgImage = context.createCGImage(image, fromRect: image.extent)
        return FindInkColor(cgImage)
    }
    
    static func FindInkColor(cgImage:CoreGraphics.CGImage) -> CIColor {
        var color = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        var lowestLuminance:CGFloat = 1.0
        
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        let componentsPerPixel = 4
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage))
        let rawData:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let numPixels = width * height
        
        for index in 0..<numPixels {
            let pixelInfo: Int = index * componentsPerPixel
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