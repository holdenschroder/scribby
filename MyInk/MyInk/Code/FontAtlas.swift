//
//  CharacterAtlas.swift
//  MyInkImageCaptureTest
//
//  Created by Galen Ryder on 2015-06-23.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import CoreData

class FontAtlas
{
    private var _characterDictionary = [String: FontAtlasGlyph]()
    static let atlasSize = CGSize(width: 2048, height: 2048)
    static let characterSize = CGSize(width: 128, height: 128)
    
    private let managedObjectContext:NSManagedObjectContext
    private let data:FontAtlasData
    private let imageData:FontAtlasImage
    
    typealias OnSaveEventHander = FontAtlas -> ()
    var onSaveEvents = [OnSaveEventHander]()
    
    init(name:String, atlasDirectory:String, managedObjectContext:NSManagedObjectContext)
    {
        self.managedObjectContext = managedObjectContext
        
        let request = NSFetchRequest(entityName: "FontAtlasData")
        let predicate = NSPredicate(format: "(name = %@)", name)
        request.predicate = predicate
        let results: [AnyObject]?
        do {
            results = try managedObjectContext.executeFetchRequest(request)
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
            data = NSEntityDescription.insertNewObjectForEntityForName("FontAtlasData", inManagedObjectContext: managedObjectContext) as! FontAtlasData
            data.name = name
            //Initialize Image
            imageData = FontAtlas.createImageData(atlasDirectory, name: name, managedObjectContext: managedObjectContext)
            data.AddImage(imageData)
            Save()
        }
    }
    
    private static func createImageData(directory:String, name:String, managedObjectContext:NSManagedObjectContext) -> FontAtlasImage {
        let newImageData = NSEntityDescription.insertNewObjectForEntityForName("FontAtlasImage", inManagedObjectContext: managedObjectContext) as! FontAtlasImage
        newImageData.filepath = "\(directory)/\(name)_atlas.png"
        UIGraphicsBeginImageContextWithOptions(FontAtlas.atlasSize, false, 1.0)
        newImageData.loadedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImageData
    }
    
    func AddGlyph(glyphMapping:String, image:UIImage, spacingCoords:CGRect, autoSave:Bool = true)
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
            gridPosition = CGRectMake(characterLinearPosition % FontAtlas.atlasSize.width, floor( characterLinearPosition / FontAtlas.atlasSize.width) * FontAtlas.characterSize.height, FontAtlas.characterSize.width, FontAtlas.characterSize.height)
            
            glyphData = NSEntityDescription.insertNewObjectForEntityForName("FontAtlasGlyph", inManagedObjectContext: managedObjectContext) as? FontAtlasGlyph
            glyphData?.image = imageData
            data.AddGlyph(glyphData!)
        }
        
        let aspectRatio = image.size.width / image.size.height
        let imageRenderHeight = FontAtlas.characterSize.height * spacingCoords.height
        let imageRenderSize = CGSize(width: aspectRatio * imageRenderHeight, height: imageRenderHeight)
        let relativeCharacterCoord:CGRect = CGRectMake(
            (FontAtlas.characterSize.width - imageRenderSize.width) * 0.5, 0, imageRenderSize.width, imageRenderSize.height)
        
        UIGraphicsBeginImageContextWithOptions(FontAtlas.atlasSize, false, 1.0)
        let cgContext = UIGraphicsGetCurrentContext()
        imageData.loadedImage!.drawInRect(CGRectMake(0, 0, FontAtlas.atlasSize.width, FontAtlas.atlasSize.height))

        var imageRenderRect = relativeCharacterCoord
        imageRenderRect.origin += gridPosition!.origin
        CGContextSetBlendMode(cgContext, CGBlendMode.Clear)
        UIColor.blackColor().setFill()
        CGContextFillRect(cgContext, gridPosition!)
        CGContextSetBlendMode(cgContext, CGBlendMode.Normal)
        image.drawInRect(imageRenderRect)
        imageData.loadedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let uvCoordinates = CGRectMake(gridPosition!.origin.x / FontAtlas.atlasSize.width, gridPosition!.origin.y / FontAtlas.atlasSize.height, gridPosition!.width / FontAtlas.atlasSize.width, gridPosition!.height / FontAtlas.atlasSize.height)
        
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
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
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
    
    func getGlyphData(mapping:String) -> FontAtlasGlyph? {
        return _characterDictionary[mapping]
    }
    
    func hasGlyphMapping(mapping:String) -> Bool {
        return _characterDictionary.indexForKey(mapping) != nil
    }
    
    var glyphLimit:Int {
        return Int((FontAtlas.atlasSize.width * FontAtlas.atlasSize.height) / (FontAtlas.characterSize.width * FontAtlas.characterSize.height))
    }
}
