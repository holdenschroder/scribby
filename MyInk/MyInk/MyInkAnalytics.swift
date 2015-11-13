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
    func TrackEvent(eventName:String)
    func TrackEvent(eventName:String, parameters:[String:String])
    func StartTimedEvent(eventName:String, parameters:[String:String]?)
    func EndTimedEvent(eventName:String, parameters:[String:String]?)
}

class MyInkAnalytics {
    static var packages:[AnalyticsPackage]?
    
    static func Initialize(packages:[AnalyticsPackage]) {
        self.packages = packages
    }
    
    static func TrackEvent(eventName:String) {
        for package in packages! {
            package.TrackEvent(eventName)
        }
    }
    
    static func TrackEvent(eventName:String, parameters:[String:String]) {
        for package in packages! {
            package.TrackEvent(eventName, parameters: parameters)
        }
    }
    
    static func StartTimedEvent(eventName:String, parameters:[String:String]?) {
        for package in packages! {
            package.StartTimedEvent(eventName, parameters: parameters)
        }
    }
    
    static func EndTimedEvent(eventName:String, parameters:[String:String]?) {
        for package in packages! {
            package.EndTimedEvent(eventName, parameters: parameters)
        }
    }
}