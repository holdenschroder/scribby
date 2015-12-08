//
//  FontAtlasImage.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-10.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import CoreData

@objc(FontAtlasImage)
class FontAtlasImage: NSManagedObject {

    @NSManaged var filepath: String
    @NSManaged var atlas: FontAtlasData
    @NSManaged var glyphs: NSSet
    
    private var _loadedImage:UIImage?
    var loadedImage:UIImage? {
        get {
            if(_loadedImage == nil) {
                let fileManager = NSFileManager.defaultManager()
                let imageData = fileManager.contentsAtPath(fullFilePath.path!)
                if(imageData != nil)
                {
                    _loadedImage = UIImage(data: imageData!)!
                }
            }
            
            return _loadedImage
        }
        set(value) {
            _loadedImage = value
        }
    }
    
    func save() {
        if _loadedImage == nil || filepath.isEmpty /*|| filepath.hasPrefix(SharedMyInkValues.EmbeddedAtlasDirectory)*/ {
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let fullFilePath = self.fullFilePath
        
        if(fileManager.fileExistsAtPath(fullFilePath.path!) == false && fullFilePath.pathComponents?.count > 0)
        {
            let filepathComponents = fullFilePath.pathComponents!
            var directoryPath = ""
            for index in 0...(filepathComponents.count - 2) {
                directoryPath += "\(filepathComponents[index])/"
            }
            
            let fileManagerError:NSErrorPointer = NSErrorPointer()
            do {
                try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                fileManagerError.memory = error
            }
            
            if(fileManagerError != nil)
            {
                print("Error creating Atlas directory: \(fileManagerError.debugDescription)")
            }
        }
        
        let atlasData = UIImagePNGRepresentation(_loadedImage!)
        if(fileManager.createFileAtPath(fullFilePath.path!, contents: atlasData, attributes: nil)) {
            print("\(fullFilePath) Atlas Saved Successfully!")
        }
        else
        {
            print("\(fullFilePath) Atlas FAILED to Save.")
        }
    }
    
    var fullFilePath:NSURL {
        get {
            var url:NSURL!
            if filepath.hasPrefix(SharedMyInkValues.EmbeddedAtlasDirectory) {
                url = NSBundle.mainBundle().URLForResource(SharedMyInkValues.EmbeddedAtlasURL, withExtension: "png")
            }
            else {
                let path = CoreDataHelper.saveDirectory
                var modifiedFilePath:String = ""
                let pathComponents = filepath.componentsSeparatedByString("/")
                for partIndex in 0..<pathComponents.count {
                    modifiedFilePath += pathComponents[partIndex] + "/"
                }
                url = path.URLByAppendingPathComponent(modifiedFilePath)
            }
            return url
        }
    }
}