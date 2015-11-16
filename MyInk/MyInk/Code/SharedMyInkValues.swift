//
//  SharedMyInkValues.swift
//  MyInk
//
//  Common Values reference throughout the app and shared between the Container App and the Keyboard Extension
//
//  Created by Galen Ryder on 2015-08-19.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class SharedMyInkValues {
    static let DefaultUserAtlas = "MyFont1"
    
    static let DefaultAtlasDirectory = "UserFonts"
    
    static let EmbeddedAtlasName = "Embedded"
    
    static let EmbeddedAtlasDirectory = "Resources"
    
    static let EmbeddedAtlasURL = "Embedded_atlas"
    
    static let EmbeddedFontDataVersion = "3"
    
    static var FontPointSizeToPixelRatio:CGFloat = {
       return UIScreen.mainScreen().scale
    }()
    
    static let MyInkPinkColor = UIColor(red: 0.93, green: 0, blue: 0.45, alpha: 1.0)
    static var MyInkWatermark:UIImage? = {
        return UIImage(named: "MyInk_Watermark")
    }()
    
    static let AppGroup = "group.myinkapp"
    
    static let Flurry_FirstPhraseEvent = "Tutorial - First Phrase"
    static let Flurry_MappedCharacter = "Mapped character"
    static let Flurry_MappedCharacter_Arg_Mapped = "Mapped"
    static let Flurry_MappedCharacter_Arg_NumAtlasChars = "NumAtlasChars"
    static let Flurry_MappedCharacter_Arg_CaptureType = "CaptureType"
}