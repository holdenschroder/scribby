//
//  FontAtlasImage.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-10.
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


@objc(FontAtlasImage)
class FontAtlasImage: NSManagedObject {

    @NSManaged var filepath: String
    @NSManaged var atlas: FontAtlasData
    @NSManaged var glyphs: NSSet
    
    fileprivate var _loadedImage: UIImage?
    var loadedImage: UIImage? {
        get {
            if(_loadedImage == nil) {
                let fileManager = FileManager.default
                let imageData = fileManager.contents(atPath: fullFilePath.path)
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
        if _loadedImage == nil || filepath.isEmpty || filepath.hasPrefix(SharedMyInkValues.EmbeddedAtlasDirectory) {
            return
        }
        
        let fileManager = FileManager.default
        let fullFilePath = self.fullFilePath
        
        if(fileManager.fileExists(atPath: fullFilePath.path) == false && fullFilePath.pathComponents.count > 0)
        {
            let filepathComponents = fullFilePath.pathComponents
            var directoryPath = ""
            for index in 0...(filepathComponents.count - 2) {
                directoryPath += "\(filepathComponents[index])/"
            }
            
            let fileManagerError:NSErrorPointer? = nil
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                fileManagerError??.pointee = error
            }
            
            if(fileManagerError != nil)
            {
                print("Error creating Atlas directory: \(fileManagerError.debugDescription)")
            }
        }
        
        let atlasData = UIImagePNGRepresentation(_loadedImage!)
        if(fileManager.createFile(atPath: fullFilePath.path, contents: atlasData, attributes: nil)) {
            print("\(fullFilePath) Atlas Saved Successfully!")
        }
        else
        {
            print("\(fullFilePath) Atlas FAILED to Save.")
        }
    }
    
    var fullFilePath:URL {
        get {
            var url:URL!
            if filepath.hasPrefix(SharedMyInkValues.EmbeddedAtlasDirectory) {
                url = Bundle.main.url(forResource: SharedMyInkValues.EmbeddedAtlasURL, withExtension: "png")
            }
            else {
                let path = CoreDataHelper.saveDirectory
                var modifiedFilePath:String = ""
                let pathComponents = filepath.components(separatedBy: "/")
                for partIndex in 0..<pathComponents.count {
                    modifiedFilePath += pathComponents[partIndex] + "/"
                }
                url = path.appendingPathComponent(modifiedFilePath)
            }
            return url
        }
    }
}
