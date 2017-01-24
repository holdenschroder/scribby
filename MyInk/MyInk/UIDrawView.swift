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
    fileprivate var lastBrushWidth: CGFloat = 0.0
    internal var mainImageView:UIImageView!
    internal var tempImageView:UIImageView!
    
    enum DrawEventType {
        case began
        case ended
        case cleared
    }
    typealias DrawEvent = (_ drawView:UIDrawView, _ eventType:DrawEventType) -> Void
    fileprivate var drawEventSubscribers = [Int:DrawEvent]()
    
    fileprivate var _isEmpty = true
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
        tempImageView.isUserInteractionEnabled = true
        self.addSubview(tempImageView)
        constrainView(tempImageView)
        tempImageView.alpha = 0.5
        self.setNeedsUpdateConstraints()
        
        //Setup User Interaction
        tempImageView.isUserInteractionEnabled = true
        
        clear()
    }
    
    fileprivate func constrainView(_ view:UIView) {
        let leftConstraint = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func clear() {
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.bounds.width, height: mainImageView.bounds.height)
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
            let context = UIGraphicsGetCurrentContext()
            context!.setFillColor(red: 0,green: 0,blue: 0,alpha: 0)
            context!.fill(imageRect)
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lastBrushWidth = brushWidthMin
        _isEmpty = true
        broadcastDrawEventToSubscribers(.cleared)
    }
    
    @IBAction func handleClearBtn(_ sender:AnyObject) {
        clear()
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {  
        let imageSize = CGSize(width: floor(tempImageView.bounds.size.width), height: floor(tempImageView.bounds.size.height))
        
        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        let pointDelta = toPoint - fromPoint;
        let scalar = min(pointDelta.magnitude() / 20, 1)
        var brushWidthFinal =  brushWidthMin + ((brushWidthMax - brushWidthMin) * scalar)
        let deltaFromLast = brushWidthFinal - lastBrushWidth
        brushWidthFinal = lastBrushWidth + Clamp(deltaFromLast, minValue: -1, maxValue: 1)
        lastBrushWidth = brushWidthFinal
        
        //println("Brush Width \(lastBrushWidth)");
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineJoin(CGLineJoin.round)
        context!.setLineWidth(brushWidthFinal)
        context!.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.normal)
        
        context!.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
        _isEmpty = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        lastBrushWidth = brushWidthMin
        if let touch = touches.first {
            lastPoint = touch.location(in: tempImageView)
            broadcastDrawEventToSubscribers(DrawEventType.began)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: tempImageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            //draw at point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        let imageRect = CGRect(x: 0, y: 0, width: mainImageView.bounds.width, height: mainImageView.bounds.height)
        
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.draw(in: imageRect, blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: imageRect, blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        broadcastDrawEventToSubscribers(DrawEventType.ended)
    }
    
    func getImage() -> UIImage {
        return mainImageView.image!
    }
    
    func addDrawEventSubscriber(_ target:AnyObject, handler:@escaping DrawEvent) {
        drawEventSubscribers[target.hash] = handler
    }
    
    func removeDrawEventSubscriber(_ target:AnyObject) {
        drawEventSubscribers.removeValue(forKey: target.hash)
    }
    
    fileprivate func broadcastDrawEventToSubscribers(_ eventType:DrawEventType) {
        for subscriber in drawEventSubscribers.values {
            subscriber(self, eventType)
        }
    }
}
