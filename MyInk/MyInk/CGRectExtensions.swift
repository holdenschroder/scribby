//
//  CGRectExtensions.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-18.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

func *(left:CGRect, right:CGSize) -> CGRect {
    var result = left
    result.origin *= right
    result.size *= right
    return result
}

func /(left:CGRect, right:CGSize) -> CGRect {
    var result = left
    result.origin /= right
    result.size /= right
    return result
}