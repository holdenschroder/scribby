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
    fileprivate var _onChangeEvents = [OnChangeEvent]()
    fileprivate var _cleared = true
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        clearImage()
        isUserInteractionEnabled = true
    }
    
    func clearImage() {
        image = nil //fillImage(UIColor(red: 1, green: 1, blue: 1, alpha: 0))
        isClear = true
        debugRect?.isHidden = true
        _cleared = true
        for event in _onChangeEvents {
            event(self, _cleared)
        }
    }
    
    @IBAction func handleClearImageBtn(_ sender:AnyObject) {
        clearImage()
    }
    
    fileprivate func fillImage(_ color:UIColor) {
        let imageRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.setBlendMode(CGBlendMode.normal)
        context!.fill(imageRect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
            if(isClear) {
                fillImage(UIColor(red: 0, green: 0, blue: 0, alpha: 1))
                isClear = false
            }
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineJoin(CGLineJoin.round)
        context!.setLineWidth(CGFloat(brushWidthRelative) * image!.size.height)
        context!.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 0)
        context!.setBlendMode(CGBlendMode.copy)
        
        context!.strokePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            //draw at point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        _cleared = false
        for event in _onChangeEvents {
            event(self, _cleared)
        }
    }
    
    func GetContentRect(_ imageSpace:Bool = false) -> CGRect
    {
        if(image != nil) {
            let image_ci = image!.ciImage != nil ? image!.ciImage! : CIImage(cgImage: image!.cgImage!)
            var rect = image_ci.extent
            
            let width = Int(rect.width)
            let firstPixel = 0
            let lastPixel = Int(floor(rect.width * rect.height))
            
            let bytesPerPixel = 4
            let rawData: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: bytesPerPixel * lastPixel)
            let context = CIContext(options: nil)
            context.render(image_ci, toBitmap: rawData, rowBytes: bytesPerPixel * Int(floor(rect.width)), bounds: rect, format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            
            var topLeft = CGPoint(x: image!.size.width, y: image!.size.height)
            var bottomRight = CGPoint.zero
        
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
            
            rawData.deinitialize()
            
            let rectSize = CGSize(width: bottomRight.x - topLeft.x, height: floor(bottomRight.y - topLeft.y))
            rect = CGRect(x: floor(topLeft.x), y: floor(topLeft.y), width: rectSize.width, height: rectSize.height)
            
            return imageSpace ? rect : convertRect(fromImage: rect)
        }
        else {
            return CGRect.zero
        }
    }
    
    func CropImageBySelection(_ imageView:UIImageView) -> CIImage? {
        if(imageView.image == nil) {
            return nil
        }
        
        let image_ui = imageView.image
        var image_ci = image_ui!.ciImage
        if(image_ci == nil) {
            image_ci = CIImage(cgImage: image_ui!.cgImage!)
        }
        var rect = GetContentRect()
        var debugRectDimensions = rect
        debugRectDimensions = convert(debugRectDimensions, to: debugRect?.superview)
        debugRect?.frame = debugRectDimensions
        debugRect?.isHidden = false
        
        let imageRect = image_ci!.extent
        if(rect == CGRect.zero) {
            rect = imageRect
        }
        else {
            rect = convert(rect, to: imageView)
            rect = imageView.convertRect(fromView: rect)
            //Compensate for mirroring issue
            rect.origin.y = imageRect.height - rect.origin.y - rect.height
        }
        
        rect = rect.integral
        
        let croppedImage = image_ci!.cropping(to: rect)
        let transform = CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y)
        let transformedImage = croppedImage.applying(transform)
        
        return transformedImage
    }
    
    func addOnChangeListener(_ callback:@escaping OnChangeEvent) {
        _onChangeEvents.append(callback)
    }
}
