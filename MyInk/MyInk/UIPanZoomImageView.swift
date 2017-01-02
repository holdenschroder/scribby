//
//  UIPanZoomImageView.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-26.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class UIPanZoomImageView: UIView
{
    fileprivate var startTouchPoint:CGPoint?
    fileprivate var pinchRecognizer:UIPinchGestureRecognizer?
    fileprivate var beginPinchScale:CGFloat = 1.0
    fileprivate var imageOffset:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    fileprivate var beginImageOffset:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    var image:UIImage? {
        didSet {
            imageOffset = CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
            setNeedsDisplay()
        }
    }
    /**
    The last area the content was drawn
    */
    fileprivate(set) var lastContentArea:CGRect?
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(UIPanZoomImageView.handlePinch(_:)))
        addGestureRecognizer(pinchRecognizer!)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startTouchPoint = touch.location(in: self)
            beginImageOffset = imageOffset
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            pan(currentPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(self)
            pan(currentPoint)
        }*/
    }
    
    func pan(_ currentPoint:CGPoint)
    {
        var offset:CGPoint = currentPoint - startTouchPoint!
        offset = offset / self.frame.size
        offset = offset * CGPoint(x: 0, y: 1)
        imageOffset.origin = beginImageOffset.origin + offset
        
        setNeedsDisplay()
    }
    
    func handlePinch(_ gestureRecognizer:UIPinchGestureRecognizer)
    {
        if(gestureRecognizer.state == UIGestureRecognizerState.began)
        {
            beginImageOffset = imageOffset
            beginPinchScale = gestureRecognizer.scale
        }
        else if(gestureRecognizer.state == UIGestureRecognizerState.changed)
        {
            let scaleDiff = gestureRecognizer.scale - beginPinchScale
            
            imageOffset.size = CGSize(width: beginImageOffset.size.width + scaleDiff, height: beginImageOffset.size.height + scaleDiff)
            
            //imageOffset.origin = CGPoint(x: (1 - imageOffset.width) * 0.5, y: beginImageOffset.origin.y - ((imageOffset.size.height - beginImageOffset.size.height) * 0.5))
            
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if(image != nil) {
            var rectAspect:CGRect?
            if(rect.width < rect.height)
            {
                rectAspect = CGRect(x: 0, y: 0, width: rect.width / rect.height, height: 1)
            }
            else
            {
                rectAspect = CGRect(x: 0, y: 0, width: 1, height: rect.height / rect.width)
            }
            
            var imageCorrection:CGRect?
            if(image!.size.width < image!.size.height)
            {
                let aspectRatio = image!.size.width / image!.size.height
                imageCorrection = CGRect(x: 0, y: 0, width: aspectRatio, height: 1)
            }
            else
            {
                let aspectRatio = image!.size.height / image!.size.width
                imageCorrection = CGRect(x: 0, y: 0, width: 1, height: aspectRatio)
            }
        
            imageCorrection!.size = (imageCorrection!.size / rectAspect!.size) * imageOffset.size
            
            var updatedRect = rect
            updatedRect.size *= imageCorrection!.size
            updatedRect.origin = imageOffset.origin * rect.size
            //Correct origin for image size
            updatedRect.origin -= CGPoint(x: updatedRect.size.width * 0.5, y: updatedRect.size.height * 0.5)
            /*let context = UIGraphicsGetCurrentContext()
            let color = UIColor.redColor()
            color.setFill()
            CGContextFillRect(context, updatedRect)*/
            image?.draw(in: updatedRect)
            UIGraphicsEndImageContext()
            
            lastContentArea = updatedRect
        }
    }
}
