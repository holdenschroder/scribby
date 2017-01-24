//
//  TutorialState.swift
//  MyInk
//  Holds Tutorial Progress Data
//
//  Created by Galen Ryder on 2015-10-03.
//  Copyright © 2015 E-Link. All rights reserved.
//

import CoreData

@objc(TutorialState)
class TutorialState:NSManagedObject {
    enum TutorialFlags:Int {
        case startingPhrase = 0
    }
    
    @NSManaged var progress:Int64
    @NSManaged var wordIndex:Int32
    
    func Initialize() {
        progress = 0
        wordIndex = 0
    }
    
    func isTutorialFlagSet(_ flag:TutorialFlags) -> Bool {
        let bit = 1 << Int64(flag.rawValue)
        return (progress & bit) != 0
    }
    
    func setTutorialFlag(_ flag:TutorialFlags) {
        let bit = 1 << Int64(flag.rawValue)
        progress |= bit
    }
    
    func unsetTutorialFlag(_ flag:TutorialFlags) {
        let bit = 1 << Int64(flag.rawValue)
        progress &= ~bit
    }
}
