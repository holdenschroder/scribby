//
//  UIDrawView.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-14.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

/**
    UIDrawView

    Spawns two ImageView children. The user touches one view to draw and when they lift their finger the created image
    is composited into the other view.
*/
class UIDrawView: UIView {
    var lastPoint = CGPoint.zero
    var swiped = false
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 1.0
    let brushWidthMin: CGFloat = 5.0
    let brushWidthMax: CGFloat = 20.0
    private var lastBrushWidth: CGFloat = 0.0
    internal var mainImageView:UIImageView!
    internal var tempImageView:UIImageView!
    
    enum DrawEventType {
        case Began
        case Ended
        case Cleared
    }
    typealias DrawEvent = (drawView:UIDrawView, eventType:DrawEventType) -> Void
    private var drawEventSubscribers = [Int:DrawEvent]()
    
    private var _isEmpty = true
    var isEmpty:Bool {
        get {
            return _isEmpty
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        
        clear()
    }
    
    private func constrainView(view:UIView) {
        let leftConstraint = NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func clear() {
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.bounds.width, height: mainImageView.bounds.height)
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
            let context = UIGraphicsGetCurrentContext()
            CGContextSetRGBFillColor(context!, 0,0,0,0)
            CGContextFillRect(context!, imageRect)
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lastBrushWidth = brushWidthMin
        _isEmpty = true
        broadcastDrawEventToSubscribers(.Cleared)
    }
    
    @IBAction func handleClearBtn(sender:AnyObject) {
        clear()
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {  
        let imageSize = CGSize(width: floor(tempImageView.bounds.size.width), height: floor(tempImageView.bounds.size.height))
        
        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        CGContextMoveToPoint(context!, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context!, toPoint.x, toPoint.y)
        
        let pointDelta = toPoint - fromPoint;
        let scalar = min(pointDelta.magnitude() / 20, 1)
        var brushWidthFinal =  brushWidthMin + ((brushWidthMax - brushWidthMin) * scalar)
        let deltaFromLast = brushWidthFinal - lastBrushWidth
        brushWidthFinal = lastBrushWidth + Clamp(deltaFromLast, minValue: -1, maxValue: 1)
        lastBrushWidth = brushWidthFinal
        
        //println("Brush Width \(lastBrushWidth)");
        
        CGContextSetLineCap(context!, CGLineCap.Round)
        CGContextSetLineJoin(context!, CGLineJoin.Round)
        CGContextSetLineWidth(context!, brushWidthFinal)
        CGContextSetRGBStrokeColor(context!, red, green, blue, 1.0)
        CGContextSetBlendMode(context!, CGBlendMode.Normal)
        
        CGContextStrokePath(context!)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
        _isEmpty = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        lastBrushWidth = brushWidthMin
        if let touch = touches.first {
            lastPoint = touch.locationInView(tempImageView)
            broadcastDrawEventToSubscribers(DrawEventType.Began)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(tempImageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            //draw at point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.bounds.width, height: mainImageView.bounds.height)
        
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(imageRect, blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(imageRect, blendMode: CGBlendMode.Normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        broadcastDrawEventToSubscribers(DrawEventType.Ended)
    }
    
    func getImage() -> UIImage {
        return mainImageView.image!
    }
    
    func addDrawEventSubscriber(target:AnyObject, handler:DrawEvent) {
        drawEventSubscribers[target.hash] = handler
    }
    
    func removeDrawEventSubscriber(target:AnyObject) {
        drawEventSubscribers.removeValueForKey(target.hash)
    }
    
    private func broadcastDrawEventToSubscribers(eventType:DrawEventType) {
        for subscriber in drawEventSubscribers.values {
            subscriber(drawView: self, eventType: eventType)
        }
    }
}
