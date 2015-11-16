//
//  ParseWrapper.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-12.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import Parse

class ParseWrapper:AnalyticsPackage {
    init(launchOptions: [NSObject: AnyObject]?) {
        //Parse uses the App Group to communicate with the Keyboard Extension
        Parse.enableDataSharingWithApplicationGroupIdentifier("group.myinkapp")
        Parse.setApplicationId("5YZOLO126JD9pt3GKmqu5JsT8UHDCouWqZVOieSE",
            clientKey: "Kf1X4TGQlbtXSF3wS0NDeDwOCAlyA5YlHPSnO8RD")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    }
    
    func TrackEvent(eventName:String) {
        PFAnalytics.trackEvent(eventName)
    }
    
    func TrackEvent(eventName:String, parameters:[String:String]) {
        PFAnalytics.trackEvent(eventName, dimensions: parameters)
    }
    
    func StartTimedEvent(eventName:String, parameters:[String:String]?) {
        PFAnalytics.trackEvent("\(eventName) Started", dimensions: parameters)
    }
    
    func EndTimedEvent(eventName:String, parameters:[String:String]?) {
        PFAnalytics.trackEvent("\(eventName) Ended", dimensions: parameters)
    }
}