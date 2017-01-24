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
    @IBInspectable var outerFillColor:UIColor!
    @IBOutlet weak var collectionView:UICollectionView!
    fileprivate var offsetRect:CGRect!
    fileprivate var isSetup = false
    fileprivate var MyObservationContext = UInt8()
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        clearsContextBeforeDrawing = true
        isUserInteractionEnabled = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        offsetRect = CGRect(x: 0.25, y: 0, width: 0.5, height: 1)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        #if !TARGET_INTERFACE_BUILDER
        setup()
        #endif
        
        let cornerRadiusSize = rect.height * 0.4
        let outerPath = UIBezierPath(roundedRect:rect, cornerRadius: cornerRadiusSize)
        outerFillColor.setFill()
        outerPath.fill()
        let handleRect = offsetRect * rect.size
        let handlePath = UIBezierPath(roundedRect: handleRect, cornerRadius: cornerRadiusSize)
        tintColor.setFill()
        handlePath.fill()
        
        let mask = CAShapeLayer(layer: self.layer)
        mask.path = outerPath.cgPath
        self.layer.mask = mask
    }
    
    func setup() {
        if(isSetup) {
            return
        }
        
        isSetup = true
        collectionView.showsHorizontalScrollIndicator = false
        
        offsetRect = CGRect(origin: collectionView.contentOffset / collectionView.contentSize, size: collectionView.bounds.size / collectionView.contentSize)
        
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &MyObservationContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard keyPath != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch (keyPath!, context) {
        case("contentOffset", .some(&MyObservationContext)):
            offsetRect = CGRect(origin: collectionView.contentOffset / collectionView.contentSize, size: collectionView.bounds.size / collectionView.contentSize)
            //offsetRect = offsetRect.intersect(CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1)))
            setNeedsDisplay()
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //MARK: Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveToTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveToTouch(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let centerPoint = collectionView.contentOffset + (collectionView.bounds.size * 0.5)
        var indexPath = collectionView.indexPathForItem(at: centerPoint)
        //If we don't find an index we need to either focus on the first or last item
        if indexPath == nil {
            if centerPoint.x < 0 {
                indexPath = IndexPath(item: 0, section: 0)
            }
            else {
                let lastSection = collectionView.numberOfSections - 1
                indexPath = IndexPath(item: collectionView.numberOfItems(inSection: lastSection) - 1, section: lastSection)
            }
        }
        
        if indexPath != nil {
            collectionView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
        }
    }
    
    func moveToTouch(_ touches:Set<UITouch>) {
        let touch = touches.first
        if(touch != nil) {
            let point = touch!.location(in: self)
            let barPercentage = point.x / bounds.width - (offsetRect.width * 0.5)
            collectionView.contentOffset = CGPoint(x: barPercentage * collectionView.contentSize.width, y: collectionView.contentOffset.y)
        }
    }
}
