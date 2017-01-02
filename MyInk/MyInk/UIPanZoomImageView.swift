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
    private var startTouchPoint:CGPoint?
    private var pinchRecognizer:UIPinchGestureRecognizer?
    private var beginPinchScale:CGFloat = 1.0
    private var imageOffset:CGRect = CGRectMake(0, 0, 1, 1)
    private var beginImageOffset:CGRect = CGRectMake(0, 0, 1, 1)
    var image:UIImage? {
        didSet {
            imageOffset = CGRectMake(0.5, 0.5, 0.5, 0.5)
            setNeedsDisplay()
        }
    }
    /**
    The last area the content was drawn
    */
    private(set) var lastContentArea:CGRect?
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(UIPanZoomImageView.handlePinch(_:)))
        addGestureRecognizer(pinchRecognizer!)
        userInteractionEnabled = true
        multipleTouchEnabled = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            startTouchPoint = touch.locationInView(self)
            beginImageOffset = imageOffset
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            pan(currentPoint)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /*if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(self)
            pan(currentPoint)
        }*/
    }
    
    func pan(currentPoint:CGPoint)
    {
        var offset:CGPoint = currentPoint - startTouchPoint!
        offset = offset / self.frame.size
        offset = offset * CGPoint(x: 0, y: 1)
        imageOffset.origin = beginImageOffset.origin + offset
        
        setNeedsDisplay()
    }
    
    func handlePinch(gestureRecognizer:UIPinchGestureRecognizer)
    {
        if(gestureRecognizer.state == UIGestureRecognizerState.Began)
        {
            beginImageOffset = imageOffset
            beginPinchScale = gestureRecognizer.scale
        }
        else if(gestureRecognizer.state == UIGestureRecognizerState.Changed)
        {
            let scaleDiff = gestureRecognizer.scale - beginPinchScale
            
            imageOffset.size = CGSize(width: beginImageOffset.size.width + scaleDiff, height: beginImageOffset.size.height + scaleDiff)
            
            //imageOffset.origin = CGPoint(x: (1 - imageOffset.width) * 0.5, y: beginImageOffset.origin.y - ((imageOffset.size.height - beginImageOffset.size.height) * 0.5))
            
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        if(image != nil) {
            var rectAspect:CGRect?
            if(rect.width < rect.height)
            {
                rectAspect = CGRectMake(0, 0, rect.width / rect.height, 1)
            }
            else
            {
                rectAspect = CGRectMake(0, 0, 1, rect.height / rect.width)
            }
            
            var imageCorrection:CGRect?
            if(image!.size.width < image!.size.height)
            {
                let aspectRatio = image!.size.width / image!.size.height
                imageCorrection = CGRectMake(0, 0, aspectRatio, 1)
            }
            else
            {
                let aspectRatio = image!.size.height / image!.size.width
                imageCorrection = CGRectMake(0, 0, 1, aspectRatio)
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
            image?.drawInRect(updatedRect)
            UIGraphicsEndImageContext()
            
            lastContentArea = updatedRect
        }
    }
}
