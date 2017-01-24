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

    func AddGlyph(_ glyph:FontAtlasGlyph)
    {
        let mutableSet = self.mutableSetValue(forKey: "glyphs")
        mutableSet.add(glyph)
        AddImage(glyph.image as! FontAtlasImage)
    }
    
    func AddImage(_ image:FontAtlasImage)
    {
        let mutableSet = self.mutableSetValue(forKey: "images")
        if(!mutableSet.contains(image)) {
            mutableSet.add(image)
        }
    }
}
