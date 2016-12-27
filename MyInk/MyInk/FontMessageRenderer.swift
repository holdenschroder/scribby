//
//  FontMessageRenderer.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-17.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
let messageBackgroundColor = UIColor(hue: 0.05, saturation: 0.1, brightness: 1, alpha: 1)

class FontMessageRenderer
{
    private var _atlas: FontAtlas
    private var _fallbackAtlas: FontAtlas
    private let _characterSpacing: CGFloat = 0.1
    private let _wordSpacing: CGFloat = 0.4
    private let _margins: CGPoint = CGPoint(x: 20, y: 30)
    private let _watermark: UIImage?

    init(atlas: FontAtlas, fallbackAtlas: FontAtlas, watermark: UIImage?) {
        _atlas = atlas
        _fallbackAtlas = fallbackAtlas
        _watermark = watermark
    }
    
    func renderMessage(message: String, imageSize: CGSize, lineHeight: CGFloat, backgroundColor: UIColor, showDebugInfo: Bool = false) -> UIImage? {
        UIGraphicsBeginImageContext(imageSize)
        let graphicsContext = UIGraphicsGetCurrentContext()
        messageBackgroundColor.setFill()
        CGContextFillRect(graphicsContext!, CGRect(origin: CGPointZero, size: imageSize))
        
        let lineComponents = message.componentsSeparatedByString("\n")
        //Lineheight is doubled because characters are stored at a 1:2 ratio
        var caretPosition: CGRect = CGRectMake(_margins.x, _margins.y, lineHeight, lineHeight)
        var renderBounds = CGRectZero
        
        var numRenderedLines = 0
        var numRenderedCharacters = 0
        var numRenderedWords = 0

        // line here is really like a paragraph
        for line in lineComponents {
            let wordComponents = line.componentsSeparatedByString(" ")
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
                if caretPosition.origin.x + wordWidth > imageSize.width - (_margins.x * 2) {
                    caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
                    numRenderedLines += 1
                }
            
                for glyphData in glyphs {
                    let imageData = glyphData.image as! FontAtlasImage
                    let subImage = UIImage(CGImage: CGImageCreateWithImageInRect(imageData.loadedImage!.CGImage!, glyphData.imageCoord * imageData.loadedImage!.size)!);
                
                    UIColor.whiteColor().setFill()
                    var characterRect = glyphData.glyphBounds
                    characterRect = characterRect * caretPosition.size
                    let renderPosition = caretPosition.offsetBy(dx: -characterRect.origin.x, dy: characterRect.origin.y)
                    
                    if showDebugInfo {
                        var debugRect = characterRect
                        debugRect.origin += CGPoint(x: renderPosition.origin.x, y: renderPosition.origin.y)
                        CGContextFillRect(graphicsContext!, debugRect)
                    }
                
                    renderBounds.unionInPlace(renderPosition)
                    subImage.drawInRect(renderPosition)
                    caretPosition.offsetInPlace(dx: (_characterSpacing * lineHeight) + characterRect.width, dy: 0)
                    numRenderedCharacters += 1
                }
            
                caretPosition.offsetInPlace(dx: _wordSpacing * lineHeight, dy: 0)
            }
            
            caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
        }
        
        //We may not have actually rendered anything if we found none of the characters
        if numRenderedCharacters > 0 {
            var renderedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let cropRect = CGRectMake(renderBounds.origin.x, renderBounds.origin.y, renderBounds.width, renderBounds.height + _margins.y)
            var croppedImage: CGImage? = CGImageCreateWithImageInRect(renderedImage!.CGImage!, cropRect)

            let aspectRatio = cropRect.width / cropRect.height
            if aspectRatio > 1.25 && numRenderedLines < numRenderedWords {
                croppedImage = nil
                renderedImage = nil
                return renderMessage(message, imageSize: CGSize(width: imageSize.width * 0.67, height: 1024), lineHeight: lineHeight, backgroundColor: backgroundColor)
            }

            return UIImage(CGImage: croppedImage!)
        }
        else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
}
