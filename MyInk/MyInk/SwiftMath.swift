//
//  SwiftMath.swift
//  MyInkTest
//
//  Created by Galen Ryder on 2015-05-12.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import Foundation
import UIKit

func Clamp(x:CGFloat, minValue:CGFloat, maxValue:CGFloat) -> CGFloat {
    var final = min(x, maxValue)
    final = max(final, minValue)
    return final
}