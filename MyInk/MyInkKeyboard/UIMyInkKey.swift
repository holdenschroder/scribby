//
//  UIMyInkKey.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-10-07.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

/** UIMyInkKey extends from UIButton and stores the KeyData class
*/
class UIMyInkKey: UIButton {
    var keyData:KeyData?
    
    convenience init(title:String, relativeWidth:CGFloat?) {
        self.init()
        self.setTitle(title, forState: .Normal)
        self.keyData = KeyData(relativeWidth: relativeWidth)
    }
    
    convenience init(icon:UIImage, relativeWidth:CGFloat?) {
        self.init()
        self.setImage(icon, forState: .Normal)
        self.keyData = KeyData(relativeWidth: relativeWidth)
    }
}

class KeyData {
    typealias Event = (UIMyInkKey, KeyData) -> Void
    
    var relativeWidth:CGFloat?
    var controlState:UIControlState = UIControlState.Normal
    var normalColorState = KeyColorState(textColor: UIColor.blackColor(), backgroundColor: UIColor.whiteColor())
    var selectedColorState = KeyColorState(textColor: UIColor.whiteColor(), backgroundColor: UIColor.lightGrayColor())
    
    init(relativeWidth:CGFloat?) {
        self.relativeWidth = relativeWidth
    }
}

struct KeyColorState {
    let tintColor:UIColor
    let backgroundColor:UIColor
    let textColor:UIColor
    
    init(tintColor:UIColor, backgroundColor:UIColor) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.textColor = UIColor.whiteColor()
    }
    
    init(textColor:UIColor, backgroundColor:UIColor) {
        self.tintColor = UIColor.whiteColor()
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}