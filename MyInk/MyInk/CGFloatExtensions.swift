//
//  CGFloatExtensions.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-18.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

func *(left:CGFloat, right:Double) -> CGFloat {
    var result = left
    result *= CGFloat(right)
    return result
}

func *=(left:CGFloat, right:Double) -> CGFloat {
    var result = left
    result *= CGFloat(right)
    return result
}
