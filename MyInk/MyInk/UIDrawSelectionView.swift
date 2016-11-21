//
//  DrawUIView.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-05-26.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit

class UIDrawSelectionView:UIImageView {
    @IBOutlet var debugRect:UIView?
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var isClear = false
    var brushWidthRelative:Float = 0.1
    
    typealias OnChangeEvent = (UIDrawSelectionView, Bool) -> Void
    private var _onChangeEvents = [OnChangeEvent]()
    private var _cleared = true
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        clearImage()
        userInteractionEnabled = true
    }
    
    func clearImage() {
        image = nil //fillImage(UIColor(red: 1, green: 1, blue: 1, alpha: 0))
        isClear = true
        debugRect?.hidden = true
        _cleared = true
        for event in _onChangeEvents {
            event(self, _cleared)
        }
    }
    
    @IBAction func handleClearImageBtn(sender:AnyObject) {
        clearImage()
    }
    
    private func fillImage(color:UIColor) {
        let imageRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextSetBlendMode(context!, CGBlendMode.Normal)
        CGContextFillRect(context!, imageRect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(self)
            if(isClear) {
                fillImage(UIColor(red: 0, green: 0, blue: 0, alpha: 1))
                isClear = false
            }
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        image?.drawInRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        CGContextMoveToPoint(context!, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context!, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context!, CGLineCap.Round)
        CGContextSetLineJoin(context!, CGLineJoin.Round)
        CGContextSetLineWidth(context!, CGFloat(brushWidthRelative) * image!.size.height)
        CGContextSetRGBStrokeColor(context!, 0, 0, 0, 0)
        CGContextSetBlendMode(context!, CGBlendMode.Copy)
        
        CGContextStrokePath(context!)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            //draw at point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        _cleared = false
        for event in _onChangeEvents {
            event(self, _cleared)
        }
    }
    
    func GetContentRect(imageSpace:Bool = false) -> CGRect
    {
        if(image != nil) {
            let image_ci = image!.CIImage != nil ? image!.CIImage! : CIImage(CGImage: image!.CGImage!)
            var rect = image_ci.extent
            
            let width = Int(rect.width)
            let firstPixel = 0
            let lastPixel = Int(floor(rect.width * rect.height))
            
            let bytesPerPixel = 4
            let rawData: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.alloc(bytesPerPixel * lastPixel)
            let context = CIContext(options: nil)
            context.render(image_ci, toBitmap: rawData, rowBytes: bytesPerPixel * Int(floor(rect.width)), bounds: rect, format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            
            var topLeft = CGPoint(x: image!.size.width, y: image!.size.height)
            var bottomRight = CGPointZero
        
            for index in firstPixel..<lastPixel {
                let pixelInfo: Int = index * bytesPerPixel
                
                let a = rawData[pixelInfo+3]
                if(a == 0)
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
            rect = CGRect(x: floor(topLeft.x), y: floor(topLeft.y), width: rectSize.width, height: rectSize.height)
            
            return imageSpace ? rect : convertRectFromImage(rect)
        }
        else {
            return CGRectZero
        }
    }
    
    func CropImageBySelection(imageView:UIImageView) -> CIImage? {
        if(imageView.image == nil) {
            return nil
        }
        
        let image_ui = imageView.image
        var image_ci = image_ui!.CIImage
        if(image_ci == nil) {
            image_ci = CIImage(CGImage: image_ui!.CGImage!)
        }
        var rect = GetContentRect()
        var debugRectDimensions = rect
        debugRectDimensions = convertRect(debugRectDimensions, toView: debugRect?.superview)
        debugRect?.frame = debugRectDimensions
        debugRect?.hidden = false
        
        let imageRect = image_ci!.extent
        if(rect == CGRectZero) {
            rect = imageRect
        }
        else {
            rect = convertRect(rect, toView: imageView)
            rect = imageView.convertRectFromView(rect)
            //Compensate for mirroring issue
            rect.origin.y = imageRect.height - rect.origin.y - rect.height
        }
        
        rect = rect.integral
        
        let croppedImage = image_ci!.imageByCroppingToRect(rect)
        let transform = CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y)
        let transformedImage = croppedImage.imageByApplyingTransform(transform)
        
        return transformedImage
    }
    
    func addOnChangeListener(callback:OnChangeEvent) {
        _onChangeEvents.append(callback)
    }
}
