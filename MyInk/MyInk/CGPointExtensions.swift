//
//  CGPointExtensions.swift
//  MyInkTest
//
//  Created by Galen Ryder on 2015-05-08.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    var result = left
    result.x += right.x
    result.y += right.y
    return result
}

func +(left:CGPoint, right:CGSize) -> CGPoint {
    var result = left
    result.x += right.width
    result.y += right.height
    return result
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    var result = left
    result.x -= right.x
    result.y -= right.y
    return result
}

func -=(inout left: CGPoint, right: CGPoint) {
    left = left - right
}

func /(left:CGPoint, right:CGPoint) -> CGPoint {
    var result = left
    result.x /= right.x
    result.y /= right.y
    return result
}

func /(left:CGPoint, right:CGSize) -> CGPoint {
    var result = left
    result.x /= right.width
    result.y /= right.height
    return result
}

func /=(inout left:CGPoint, right:CGSize) {
    left = left / right
}

func *(left:CGPoint, right:CGPoint) -> CGPoint {
    var result = left
    result.x *= right.x
    result.y *= right.y
    return result
}

func *(left:CGPoint, right:CGSize) -> CGPoint {
    var result = left
    result.x *= right.width
    result.y *= right.height
    return result
}

func *=(inout left:CGPoint, right:CGPoint) {
    left = left * right
}

func *=(inout left:CGPoint, right:CGSize) {
    left = left * right
}

func -(left:CGPoint, right:CGSize) -> CGPoint {
    var result = left
    result.x -= right.width
    result.y -= right.height
    return result
}

func *(left:CGFloat, right:Int) -> CGFloat {
    var result = left
    result = result * CGFloat(right)
    return result
}

func /(left:CGFloat, right:Int) -> CGFloat {
    var result = left
    result = result / CGFloat(right)
    return result
}

extension CGPoint
{
    func magnitude() -> CGFloat {
        return abs((x + y) / 2)
    }
}
