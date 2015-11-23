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
    
    static let kEventScreenLoadedCapturePhotoTaken =        "SCREEN_CAPTURE_PHOTO-TAKEN"
    static let kEventScreenLoadedCaptureCharacterSelect =   "SCREEN_CAPTURE_CHARACTER-SELECT"
    static let kEventScreenLoadedCaptureWordSelect =        "SCREEN_CAPTURE_WORD-SELECT"
    static let kEventScreenLoadedCaptureMapGlyph =          "SCREEN_CAPTURE_MAP-GLYPH"
    static let kEventScreenLoadedCaptureSetupCharacter =    "SCREEN_CAPTURE_SETUP-CHARACTER"
    static let kEventScreenLoadedCaptureTouch =             "SCREEN_CAPTURE_TOUCH"
    
    static let kEventScreenLoadedComposeMessage =           "SCREEN_COMPOSE"
    static let kEventScreenLoadedLibraryList =              "SCREEN_LIBRARY_LIST"
    static let kEventScreenLoadedLibraryItem =              "SCREEN_LIBRARY_ITEM"
    static let kEventScreenLoadedLibraryPhotoTaken =        "SCREEN_LIBRARY_PHOTO-TAKEN"
    static let kEventScreenLoadedKeyboardInstructions =     "SCREEN_KEYBOARD_INSTRUCTIONS"
    static let kEventScreenLoadedKeyboardAllPages =         "SCREEN_KEYBOARD_INSTRUCTIONS-ALL-PAGES"

    
    static let kEventScreenLoadedMainMenu =                 "SCREEN_MENU"
    static let kEventScreenLoadedShareImage =               "SCREEN_SHARE-IMAGE"
    
    static let kEventTutorialWordStarted =                  "TUTORIAL_WORD-STARTED"
    static let kEventTutorialWordFinished =                 "TUTORIAL_WORD-FINISHED"
    static let kEventTutorialFirstPhrase =                  "TUTORIAL_FIRST-PHRASE"
    static let kEventTutorialSkipped =                      "TUTORIAL_SKIPPED"
    static let kEventTutorialFinished =                     "TUTORIAL_FINISHED"

    
    static let kEventKeyboardAppeared =                     "KEYBOARD-APPEARED"
    static let kEventKeyboardDisappeared =                  "KEYBOARD-DISAPPEARED"
    static let kEventKeyboardSwitched =                     "KEYBOARD-SWITCHED"
    
    static let kEventShareMessage =                         "SHARE-MESSAGE"
    static let kEventShareMessageParameterActivity =        "SHARE-MESSAGE-ACTIVITY"
    
    static let kEventRenderMessage =                        "RENDER-MESSAGE"
    
    static let kEventMappedCharacter =                      "MAPPED-CHARACTER"
    static let kEventMappedCharacterArgMapped =             "MAPPED"
    static let kEventMappedCharacterArgNumAtlasChars =      "NUM-ATLAS-CHARS"
    static let kEventMappedCharacterArgCaptureType =        "CAPTURE-TYPE"
    
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

}