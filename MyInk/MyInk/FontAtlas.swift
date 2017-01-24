//
//  CharacterAtlas.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-23.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FontAtlas
{
    fileprivate var _characterDictionary = [String: FontAtlasGlyph]()
    static let atlasSize = CGSize(width: 2048, height: 2048)
    static let characterSize = CGSize(width: 128, height: 128)
    
    fileprivate let managedObjectContext:NSManagedObjectContext
    fileprivate let data:FontAtlasData
    fileprivate let imageData:FontAtlasImage
    
    typealias OnSaveEventHander = (FontAtlas) -> ()
    var onSaveEvents = [OnSaveEventHander]()

    static var main: FontAtlas {
        return FontAtlas(name: SharedMyInkValues.DefaultUserAtlas, atlasDirectory: SharedMyInkValues.DefaultAtlasDirectory, managedObjectContext: CoreDataHelper().managedObjectContext!)
    }

    static var fallback: FontAtlas {
        return FontAtlas(name: SharedMyInkValues.EmbeddedAtlasName, atlasDirectory: SharedMyInkValues.EmbeddedAtlasDirectory, managedObjectContext: CoreDataHelper().embeddedManagedObjectContext!)
    }

    init(name: String, atlasDirectory: String, managedObjectContext: NSManagedObjectContext)
    {
        self.managedObjectContext = managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FontAtlasData")
        let predicate = NSPredicate(format: "(name = %@)", name)
        request.predicate = predicate
        let results: [AnyObject]?
        do {
            results = try managedObjectContext.fetch(request)
        } catch let error1 as NSError {
            results = nil
            print("Error Initializing Atlas \(error1.description)")
        }
    
        if(results?.count > 0) {
            data = results?.first as! FontAtlasData
            if data.images.allObjects.count > 0 {
                imageData = data.images.allObjects.first as! FontAtlasImage
            }
            else {
                imageData = FontAtlas.createImageData(atlasDirectory, name: name, managedObjectContext: managedObjectContext)
                data.AddImage(imageData)
                Save()
            }
            
            //Fill Dictionary
            for glyph in data.glyphs.allObjects as! [FontAtlasGlyph] {
                _characterDictionary[glyph.mapping] = glyph
            }
        }
        else {
            //Initialize Atlas
            data = NSEntityDescription.insertNewObject(forEntityName: "FontAtlasData", into: managedObjectContext) as! FontAtlasData
            data.name = name
            //Initialize Image
            imageData = FontAtlas.createImageData(atlasDirectory, name: name, managedObjectContext: managedObjectContext)
            data.AddImage(imageData)
            Save()
        }
    }
    
    fileprivate static func createImageData(_ directory:String, name:String, managedObjectContext:NSManagedObjectContext) -> FontAtlasImage {
        let newImageData = NSEntityDescription.insertNewObject(forEntityName: "FontAtlasImage", into: managedObjectContext) as! FontAtlasImage
        newImageData.filepath = "\(directory)/\(name)_atlas.png"
        UIGraphicsBeginImageContextWithOptions(FontAtlas.atlasSize, false, 1.0)
        newImageData.loadedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImageData
    }
    
    func AddGlyph(_ glyphMapping:String, image:UIImage, spacingCoords:CGRect, autoSave:Bool = true)
    {
        var glyphData = _characterDictionary[glyphMapping]
        var gridPosition:CGRect?
        if(glyphData != nil) {
            gridPosition = glyphData?.imageCoord
            gridPosition?.origin *= FontAtlas.atlasSize
            gridPosition?.size *= FontAtlas.atlasSize
        }
        else {
            if imageData.glyphs.count >= glyphLimit {
                return
            }
            
            let characterLinearPosition = CGFloat(imageData.glyphs.count) * FontAtlas.characterSize.width
            gridPosition = CGRect(x: characterLinearPosition.truncatingRemainder(dividingBy: FontAtlas.atlasSize.width), y: floor( characterLinearPosition / FontAtlas.atlasSize.width) * FontAtlas.characterSize.height, width: FontAtlas.characterSize.width, height: FontAtlas.characterSize.height)
            
            glyphData = NSEntityDescription.insertNewObject(forEntityName: "FontAtlasGlyph", into: managedObjectContext) as? FontAtlasGlyph
            glyphData?.image = imageData
            data.AddGlyph(glyphData!)
        }
        
        let aspectRatio = image.size.width / image.size.height
        let imageRenderHeight = FontAtlas.characterSize.height * spacingCoords.height
        let imageRenderSize = CGSize(width: aspectRatio * imageRenderHeight, height: imageRenderHeight)
        let relativeCharacterCoord:CGRect = CGRect(
            x: (FontAtlas.characterSize.width - imageRenderSize.width) * 0.5, y: 0, width: imageRenderSize.width, height: imageRenderSize.height)
        
        UIGraphicsBeginImageContextWithOptions(FontAtlas.atlasSize, false, 1.0)
        let cgContext = UIGraphicsGetCurrentContext()
        imageData.loadedImage!.draw(in: CGRect(x: 0, y: 0, width: FontAtlas.atlasSize.width, height: FontAtlas.atlasSize.height))

        var imageRenderRect = relativeCharacterCoord
        imageRenderRect.origin += gridPosition!.origin
        cgContext!.setBlendMode(CGBlendMode.clear)
        UIColor.black.setFill()
        cgContext!.fill(gridPosition!)
        cgContext!.setBlendMode(CGBlendMode.normal)
        image.draw(in: imageRenderRect)
        imageData.loadedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let uvCoordinates = CGRect(x: gridPosition!.origin.x / FontAtlas.atlasSize.width, y: gridPosition!.origin.y / FontAtlas.atlasSize.height, width: gridPosition!.width / FontAtlas.atlasSize.width, height: gridPosition!.height / FontAtlas.atlasSize.height)
        
        //The vertical coordinates of the FontAtlasGlyph.glyphBounds stores the relative position of the top of the glyph against the topline in the y coordinate,
        //with the relative size of the character in the lineheight. We should not modify these numbers.
        //But the horizontal coordinates are used to determine the left side (x) and the width of the glyph and those are in glyph image space at the moment
        //We need to modify those to change them to atlas cell coordinates
        var modifiedSpacingCoords = spacingCoords * imageRenderRect.size
        modifiedSpacingCoords.origin += imageRenderRect.origin - gridPosition!.origin
        modifiedSpacingCoords = modifiedSpacingCoords / gridPosition!.size
        
        glyphData!.mapping = glyphMapping
        glyphData!.imageCoord = uvCoordinates
        glyphData!.glyphBounds = CGRect(x: modifiedSpacingCoords.origin.x, y: spacingCoords.origin.y, width: modifiedSpacingCoords.width, height: spacingCoords.height)
        
        _characterDictionary[glyphMapping] = glyphData!
        
        if(autoSave) {
            Save()
        }
    }
    
    func Save()
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
            for image in self.data.images.allObjects as! [FontAtlasImage] {
                image.save()
            }
            
            for event in self.onSaveEvents {
                event(self)
            }
        })
    }
    
    var glyphs:[FontAtlasGlyph] {
        get {
            let glyphArr = data.glyphs.allObjects as! [FontAtlasGlyph]
            return glyphArr
        }
    }
    
    func getGlyphData(_ mapping:String) -> FontAtlasGlyph? {
        return _characterDictionary[mapping]
    }
    
    func hasGlyphMapping(_ mapping:String) -> Bool {
        return _characterDictionary.index(forKey: mapping) != nil
    }
    
    var glyphLimit:Int {
        return Int((FontAtlas.atlasSize.width * FontAtlas.atlasSize.height) / (FontAtlas.characterSize.width * FontAtlas.characterSize.height))
    }
}
