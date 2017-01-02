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
    init(launchOptions: [AnyHashable: Any]?) {
        //Parse uses the App Group to communicate with the Keyboard Extension
        Parse.enableDataSharing(withApplicationGroupIdentifier: SharedMyInkValues.AppGroup)
        Parse.setApplicationId("5YZOLO126JD9pt3GKmqu5JsT8UHDCouWqZVOieSE",
            clientKey: "Kf1X4TGQlbtXSF3wS0NDeDwOCAlyA5YlHPSnO8RD")
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
    }
    
    func TrackEvent(_ eventName:String) {
        PFAnalytics.trackEvent(eventName)
    }
    
    func TrackEvent(_ eventName:String, parameters:[String:String]) {
        PFAnalytics.trackEvent(eventName, dimensions: parameters)
    }
    
    func StartTimedEvent(_ eventName:String, parameters:[String:String]?) {
        PFAnalytics.trackEvent("\(eventName)_Started", dimensions: parameters)
    }
    
    func EndTimedEvent(_ eventName:String, parameters:[String:String]?) {
        PFAnalytics.trackEvent("\(eventName)_Ended", dimensions: parameters)
    }
}
