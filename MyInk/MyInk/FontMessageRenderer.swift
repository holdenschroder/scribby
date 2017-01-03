//
//  FontMessageRenderer.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-17.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
let beigeMessageBackgroundColor = UIColor(hue: 0.05, saturation: 0.1, brightness: 1, alpha: 1)

class FontMessageRenderer
{
    fileprivate var _atlas: FontAtlas
    fileprivate var _fallbackAtlas: FontAtlas
    fileprivate let _characterSpacing: CGFloat = 0.1
    fileprivate let _wordSpacing: CGFloat = 0.4
    fileprivate let _margins: CGPoint = CGPoint(x: 20, y: 30)
    fileprivate let _watermark: UIImage?

    init(atlas: FontAtlas, fallbackAtlas: FontAtlas, watermark: UIImage?) {
        _atlas = atlas
        _fallbackAtlas = fallbackAtlas
        _watermark = watermark
    }
    
    func renderMessage(_ message: String, imageSize: CGSize, lineHeight: CGFloat, backgroundColor: UIColor, showDebugInfo: Bool = false, maxLineWidth: CGFloat? = nil) -> UIImage? {

        let maxWidth = maxLineWidth ?? imageSize.width
        let shouldEnforceAspectRatio = maxLineWidth != nil

        UIGraphicsBeginImageContext(imageSize)
        let graphicsContext = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        graphicsContext!.fill(CGRect(origin: CGPoint.zero, size: imageSize))
        
        let lineComponents = message.components(separatedBy: "\n")
        //Lineheight is doubled because characters are stored at a 1:2 ratio
        var caretPosition: CGRect = CGRect(x: _margins.x, y: _margins.y, width: lineHeight, height: lineHeight)
        var renderBounds = CGRect.zero
        
        var numRenderedLines = 0
        var numRenderedCharacters = 0
        var numRenderedWords = 0

        // line here is really like a paragraph
        for line in lineComponents {
            let wordComponents = line.components(separatedBy: " ")
            numRenderedLines += 1
            for word in wordComponents {
                var glyphs = [FontAtlasGlyph]()
                var wordWidth: CGFloat = 0
                for character in word.characters {
                    let characterString = String(character)
                    var glyphData: FontAtlasGlyph?
                    if _atlas.hasGlyphMapping(characterString) {
                        glyphData = _atlas.getGlyphData(characterString)
                    }
                    else if _fallbackAtlas.hasGlyphMapping(characterString) {
                        glyphData = _fallbackAtlas.getGlyphData(characterString)
                    }
                    
                    if glyphData != nil {
                        glyphs.append(glyphData!)
                        wordWidth += glyphData!.glyphBounds.width * caretPosition.width
                    }
                }
            
                if glyphs.count > 0 {
                    wordWidth += (_characterSpacing * lineHeight) * CGFloat(glyphs.count - 1)
                    numRenderedWords += 1
                }
            
                //Do we have space left on this line?
                if caretPosition.origin.x + wordWidth > maxWidth - (_margins.x * 2) {
                    caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
                    numRenderedLines += 1
                }
            
                for (i, glyphData) in glyphs.enumerated() {
                    print("Rendering character '\(word[word.index(word.startIndex, offsetBy: i)])'")
                    let imageData = glyphData.image as! FontAtlasImage
                    let subImage = UIImage(cgImage: imageData.loadedImage!.cgImage!.cropping(to: glyphData.imageCoord * imageData.loadedImage!.size)!);
                
                    UIColor.white.setFill()
                    var characterRect = glyphData.glyphBounds
                    characterRect = characterRect * caretPosition.size
                    let renderPosition = caretPosition.offsetBy(dx: -characterRect.origin.x, dy: characterRect.origin.y)
                    
                    if showDebugInfo {
                        var debugRect = characterRect
                        debugRect.origin += CGPoint(x: renderPosition.origin.x, y: renderPosition.origin.y)
                        graphicsContext!.fill(debugRect)
                    }
                    print("Bounds before union: \(renderBounds), New Position: \(renderPosition)")
                    renderBounds = renderBounds.union(renderPosition)
                    print("Bounds  after union: \(renderBounds)\n")
                    subImage.draw(in: renderPosition)
                    caretPosition = caretPosition.offsetBy(dx: (_characterSpacing * lineHeight) + characterRect.width, dy: 0)
                    numRenderedCharacters += 1
                }
            
                caretPosition = caretPosition.offsetBy(dx: _wordSpacing * lineHeight, dy: 0)
            }
            
            caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
        }
        
        //We may not have actually rendered anything if we found none of the characters
        if numRenderedCharacters > 0 {
            var renderedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let cropRect = CGRect(x: renderBounds.origin.x, y: renderBounds.origin.y, width: renderBounds.width + _margins.x, height: renderBounds.height + _margins.y)
            var croppedImage: CGImage? = renderedImage!.cgImage!.cropping(to: cropRect)

            let aspectRatio = cropRect.width / cropRect.height
            print("Cropped rect      : \(cropRect)")
            print("Image width: \(imageSize.width)")
            print("Aspect Ratio: \(aspectRatio)\n\n**************************\n")
            // 1.25
            if shouldEnforceAspectRatio && aspectRatio > 1.25 && numRenderedLines < numRenderedWords {
                croppedImage = nil
                renderedImage = nil
                return renderMessage(message, imageSize: CGSize(width: imageSize.width, height: 1024), lineHeight: lineHeight, backgroundColor: backgroundColor, showDebugInfo: showDebugInfo, maxLineWidth: maxWidth * 0.67)
            }

            return UIImage(cgImage: croppedImage!)
        }
        else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
}
