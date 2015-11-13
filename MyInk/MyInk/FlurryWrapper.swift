//
//  FlurryWrapper.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-12.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation

class FlurryWrapper:AnalyticsPackage {
    init() {
        Flurry.startSession("843TZFS358BTRKCZRZ4R")
    }
    
    func TrackEvent(eventName:String) {
        Flurry.logEvent(eventName)
    }
    
    func TrackEvent(eventName:String, parameters:[String:String]) {
        Flurry.logEvent(eventName, withParameters: parameters)
    }
    
    func StartTimedEvent(eventName:String, parameters:[String:String]?) {
        Flurry.logEvent(eventName, withParameters: parameters, timed: true)
    }
    
    func EndTimedEvent(eventName:String, parameters:[String:String]?) {
        Flurry.endTimedEvent(eventName, withParameters: parameters)
    }
}