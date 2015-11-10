//
//  UIDrawView.swift
//  MyInkDrawingTest
//
//  Created by Galen Ryder on 2015-09-14.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class UIDrawView: UIView {
    var lastPoint = CGPoint.zeroPoint
    var swiped = false
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 1.0
    let brushWidthMin: CGFloat = 2.0
    let brushWidthMax: CGFloat = 4.0
    var lastBrushWidth: CGFloat = 0
    
    private var mainImageView:UIImageView!
    private var tempImageView:UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mainImageView = UIImageView(frame: frame)
        self.addSubview(mainImageView)
        constrainView(mainImageView)
        tempImageView = UIImageView(frame: frame)
        tempImageView.userInteractionEnabled = true
        self.addSubview(tempImageView)
        constrainView(tempImageView)
        tempImageView.alpha = 0.5
        self.setNeedsUpdateConstraints()
        
        //Setup User Interaction
        tempImageView.userInteractionEnabled = true
        
        clearImage()
    }
    
    private func constrainView(view:UIView) {
        let leftConstraint = NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    func clearImage() {
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.frame.width, height: mainImageView.frame.height)
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        CGContextFillRect(context, imageRect)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    @IBAction func handleClearBtn(sender:AnyObject) {
        clearImage()
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: tempImageView.frame.width, height: tempImageView.frame.height))
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        let pointDelta = toPoint - fromPoint;
        let scalar = min(pointDelta.magnitude() / 10, 1)
        var brushWidthFinal =  brushWidthMin + ((brushWidthMax - brushWidthMin) * scalar)
        lastBrushWidth = brushWidthFinal
        
        //println("Brush Width \(lastBrushWidth)");
        
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineJoin(context, kCGLineJoinRound)
        CGContextSetLineWidth(context, brushWidthFinal)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        lastBrushWidth = brushWidthMin
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(tempImageView)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = true
        if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(tempImageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !swiped {
            //draw at point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.frame.width, height: mainImageView.frame.height)
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(imageRect, blendMode: kCGBlendModeNormal, alpha: 1.0)
        tempImageView.image?.drawInRect(imageRect, blendMode: kCGBlendModeNormal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
}
