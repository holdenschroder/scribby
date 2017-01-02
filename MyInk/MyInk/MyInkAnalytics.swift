//
//  MyInkAnalytics.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-11-12.
//  Copyright © 2015 E-Link. All rights reserved.
//

import Foundation
import Parse

protocol AnalyticsPackage {
    func TrackEvent(_ eventName:String)
    func TrackEvent(_ eventName:String, parameters:[String:String])
    func StartTimedEvent(_ eventName:String, parameters:[String:String]?)
    func EndTimedEvent(_ eventName:String, parameters:[String:String]?)
}

class MyInkAnalytics {
    static var packages:[AnalyticsPackage]?
    
    static func Initialize(_ packages:[AnalyticsPackage]) {
        self.packages = packages
    }
    
    static func TrackEvent(_ eventName:String) {
        for package in packages! {
            package.TrackEvent(eventName)
        }
    }
    
    static func TrackEvent(_ eventName:String, parameters:[String:String]) {
        for package in packages! {
            package.TrackEvent(eventName, parameters: parameters)
        }
    }
    
    static func StartTimedEvent(_ eventName:String, parameters:[String:String]?) {
        for package in packages! {
            package.StartTimedEvent(eventName, parameters: parameters)
        }
    }
    
    static func EndTimedEvent(_ eventName:String, parameters:[String:String]?) {
        for package in packages! {
            package.EndTimedEvent(eventName, parameters: parameters)
        }
    }
}
