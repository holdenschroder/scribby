//
//  CustomScrollBar.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-13.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

@IBDesignable
class UICustomScrollBar: UIView, UIScrollViewDelegate {
    @IBInspectable var innerFillColor:UIColor!
    @IBInspectable var outerFillColor:UIColor!
    @IBOutlet weak var scrollView:UIScrollView!
    private var offsetRect:CGRect!
    private var isSetup = false
    private var MyObservationContext = UInt8()
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        opaque = false
        userInteractionEnabled = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        offsetRect = CGRect(x: 0.25, y: 0, width: 0.5, height: 1)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        #if !TARGET_INTERFACE_BUILDER
        setup()
        #endif
        
        let cornerRadiusSize = rect.height * 0.4
        let outerPath = UIBezierPath(roundedRect:rect, cornerRadius: cornerRadiusSize)
        outerFillColor.setFill()
        outerPath.fill()
        let innerRect = offsetRect * rect.size
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: cornerRadiusSize)
        innerFillColor.setFill()
        innerPath.fill()
    }
    
    func setup() {
        if(isSetup) {
            return
        }
        
        isSetup = true
        scrollView.showsHorizontalScrollIndicator = false
        
        offsetRect = CGRect(origin: scrollView.contentOffset / scrollView.contentSize, size: scrollView.bounds.size / scrollView.contentSize)
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &MyObservationContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        switch (keyPath!, context) {
        case("contentOffset", &MyObservationContext):
            offsetRect = CGRect(origin: scrollView.contentOffset / scrollView.contentSize, size: scrollView.bounds.size / scrollView.contentSize)
            offsetRect = offsetRect.intersect(CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1)))
            setNeedsDisplay()
            
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    //MARK: Touch Handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        moveToTouch(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        moveToTouch(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    func moveToTouch(touches:Set<UITouch>) {
        let touch = touches.first
        if(touch != nil) {
            let point = touch!.locationInView(self)
            if self.bounds.contains(point) {
                let barPercentage = point.x / bounds.width - (offsetRect.width * 0.5)
                scrollView.contentOffset = CGPoint(x: barPercentage * scrollView.contentSize.width, y: scrollView.contentOffset.y)
            }
        }
    }
}
