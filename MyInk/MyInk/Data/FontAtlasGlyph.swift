//
//  FontAtlasCharacter.swift
//  
//
//  Created by Galen Ryder on 2015-07-09.
//
//

import Foundation
import CoreData
import UIKit

@objc(FontAtlasGlyph)
class FontAtlasGlyph: NSManagedObject {

    @NSManaged var mapping: String
    @NSManaged var imageCoordAsString: String
    @NSManaged var glyphBoundsAsString:String
    @NSManaged var leftConnectionAsString: String
    @NSManaged var rightConnectionAsString: String
    @NSManaged var atlas: NSManagedObject
    @NSManaged var image: NSManagedObject
    
    fileprivate var storedImageCoord:CGRect?
    fileprivate var storedGlyphBounds:CGRect?
    
    var imageCoord:CGRect {
        get {
            if(storedImageCoord == nil) {
                storedImageCoord = CGRectFromString(imageCoordAsString)
            }
            return storedImageCoord!
        }
        set(newValue)
        {
            storedImageCoord = newValue
            imageCoordAsString = NSStringFromCGRect(newValue)
        }
    }
    
    /** This isn't quite a traditional bounds. The X and Width components are used to determine the left position of the glyph within the image cell and the relative width within the the cell. The Y coordinate is the distance between the topline and the top of the glyph. The height component is the relative size of glyph vs line height.
    */
    var glyphBounds:CGRect {
        get {
            if(storedGlyphBounds == nil) {
                storedGlyphBounds = CGRectFromString(glyphBoundsAsString)
            }
            return storedGlyphBounds!
        }
        set(newValue) {
            storedGlyphBounds = newValue
            glyphBoundsAsString = NSStringFromCGRect(newValue)
        }
    }
}
