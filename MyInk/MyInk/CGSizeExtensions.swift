//
//  CGSizeExtensions.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-18.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

func +(left:CGSize, right:CGSize) -> CGSize {
    var result = left
    result.width += right.width
    result.height += right.height
    return result
}

func *(left:CGSize, right:CGSize) -> CGSize {
    var result = left
    result.width *= right.width
    result.height *= right.height
    return result
}

func *(left:CGSize, right:CGFloat) -> CGSize {
    var result = left
    result.width *= right
    result.height *= right
    return result
}

func *=(inout left:CGSize, right:CGSize) {
    left = left * right
}

func /(left:CGSize, right:CGSize) -> CGSize {
    var result = left
    result.width /= right.width
    result.height /= right.height
    return result
}

func /=(inout left:CGSize, right:CGSize) {
    left = left / right
}