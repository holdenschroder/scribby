//
//  FontAtlasData.swift
//  
//
//  Created by Galen Ryder on 2015-07-09.
//
//

import Foundation
import CoreData

@objc(FontAtlasData)
class FontAtlasData: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var imageFileName: String
    @NSManaged var glyphs:NSSet
    @NSManaged var images:NSSet

    func AddGlyph(glyph:FontAtlasGlyph)
    {
        let mutableSet = self.mutableSetValueForKey("glyphs")
        mutableSet.addObject(glyph)
        AddImage(glyph.image as! FontAtlasImage)
    }
    
    func AddImage(image:FontAtlasImage)
    {
        let mutableSet = self.mutableSetValueForKey("images")
        if(!mutableSet.containsObject(image)) {
            mutableSet.addObject(image)
        }
    }
}
