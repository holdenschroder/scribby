//
//  KeyboardAnalytics.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-12.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import Parse

class KeyboardAnalytics {
    static func Initialize() {
        Parse.enableDataSharing(withApplicationGroupIdentifier: SharedMyInkValues.AppGroup, containingApplication: SharedMyInkValues.AppParent)
        Parse.setApplicationId("5YZOLO126JD9pt3GKmqu5JsT8UHDCouWqZVOieSE", clientKey: "Kf1X4TGQlbtXSF3wS0NDeDwOCAlyA5YlHPSnO8RD")
        PFAnalytics.trackAppOpened(launchOptions: nil)
    }
    
    static func TrackEvent(_ eventName:String) {
        PFAnalytics.trackEvent(eventName)
    }
    
    static func TrackEvent(_ eventName:String, parameters:[String:String]) {
        PFAnalytics.trackEvent(eventName, dimensions: parameters)
    }
}
