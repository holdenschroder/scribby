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

func +(left: CGPoint, right: CGSize) -> CGPoint {
    var result = left
    result.x += right.width
    result.y += right.height
    return result
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    var result = left
    result.x -= right.x
    result.y -= right.y
    return result
}

func -=(left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func /(left: CGPoint, right: CGPoint) -> CGPoint {
    var result = left
    result.x /= right.x
    result.y /= right.y
    return result
}

func /(left: CGPoint, right: CGSize) -> CGPoint {
    var result = left
    result.x /= right.width
    result.y /= right.height
    return result
}

func /=(left: inout CGPoint, right: CGSize) {
    left = left / right
}

func *(left: CGPoint, right: CGPoint) -> CGPoint {
    var result = left
    result.x *= right.x
    result.y *= right.y
    return result
}

func *(left: CGPoint, right: CGSize) -> CGPoint {
    var result = left
    result.x *= right.width
    result.y *= right.height
    return result
}

func *=(left:inout CGPoint, right:CGPoint) {
    left = left * right
}

func *=(left:inout CGPoint, right:CGSize) {
    left = left * right
}

func -(left:CGPoint, right:CGSize) -> CGPoint {
    var result = left
    result.x -= right.width
    result.y -= right.height
    return result
}

func *(left: CGFloat, right: Int) -> CGFloat {
    var result = left
    result = result * CGFloat(right)
    return result
}

func /(left: CGFloat, right: Int) -> CGFloat {
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

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: rhs.x * lhs, y: rhs.y * lhs)
}

func +(lhs: CGPoint, rhs: UIOffset) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.horizontal, y: lhs.y + rhs.vertical)
}

func +=(lhs: inout CGPoint, rhs: UIOffset) {
    lhs.x += rhs.horizontal
    lhs.y += rhs.vertical
}

// UIOffset Extensions

func +(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
    return UIOffset(horizontal: lhs.horizontal + rhs.horizontal, vertical: lhs.vertical + rhs.vertical)
}
