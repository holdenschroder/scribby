//
//  FontMessageRenderer.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-17.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class FontMessageRenderer
{
    private var _atlas:FontAtlas
    private var _fallbackAtlas:FontAtlas
    private let _characterSpacing:CGFloat = 0.1
    private let _wordSpacing:CGFloat = 0.4
    private let _margins:CGPoint = CGPoint(x: 10, y: 10)
    private let _watermark:UIImage?

    init(atlas:FontAtlas, fallbackAtlas:FontAtlas, watermark:UIImage?) {
        _atlas = atlas
        _fallbackAtlas = fallbackAtlas
        _watermark = watermark
    }
    
    func renderMessage(message:String, imageSize:CGSize, lineHeight:CGFloat, backgroundColor:UIColor, showDebugInfo:Bool = false) -> UIImage? {
        UIGraphicsBeginImageContext(imageSize)
        let graphicsContext = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        CGContextFillRect(graphicsContext, CGRect(origin: CGPointZero, size: imageSize))
        
        let lineComponents = message.componentsSeparatedByString("\n")
        //Lineheight is doubled because characters are stored at a 1:2 ratio
        var caretPosition:CGRect = CGRectMake(_margins.x, _margins.y, lineHeight, lineHeight)
        var renderBounds = CGRectZero
        
        var numRenderedLines = 0
        var numRenderedCharacters = 0
        for line in lineComponents {
            let wordComponents = line.componentsSeparatedByString(" ")
            ++numRenderedLines
            for word in wordComponents {
                var glyphs = [FontAtlasGlyph]()
                var wordWidth:CGFloat = 0
                for character in word.characters {
                    let characterString = String(character)
                    var glyphData:FontAtlasGlyph?
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
                }
            
                //Do we have space left on this line?
                if caretPosition.origin.x + wordWidth > imageSize.width - (_margins.x * 2) {
                    caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
                    ++numRenderedLines
                }
            
                for glyphData in glyphs {
                    let imageData = glyphData.image as! FontAtlasImage
                    let subImage = UIImage(CGImage: CGImageCreateWithImageInRect(imageData.loadedImage!.CGImage, glyphData.imageCoord * imageData.loadedImage!.size)!);
                
                    UIColor.whiteColor().setFill()
                    var characterRect = glyphData.glyphBounds
                    characterRect = characterRect * caretPosition.size
                    let renderPosition = caretPosition.offsetBy(dx: -characterRect.origin.x, dy: characterRect.origin.y)
                    
                    if showDebugInfo {
                        var debugRect = characterRect
                        debugRect.origin += CGPoint(x: renderPosition.origin.x, y: renderPosition.origin.y)
                        CGContextFillRect(graphicsContext, debugRect)
                    }
                
                    renderBounds.unionInPlace(renderPosition)
                    subImage.drawInRect(renderPosition)
                    caretPosition.offsetInPlace(dx: (_characterSpacing * lineHeight) + characterRect.width, dy: 0)
                    ++numRenderedCharacters
                }
            
                caretPosition.offsetInPlace(dx: _wordSpacing * lineHeight, dy: 0)
            }
            
            caretPosition.origin = CGPoint(x: _margins.x, y: caretPosition.origin.y + lineHeight)
        }
        
        //We may not have actually rendered anything if we found none of the characters
        if numRenderedCharacters > 0 {
            renderBounds.size.height = renderBounds.size.height + _margins.y
            
            //We can add the watermark here, which will increase the renderBounds
            if _watermark != nil {
                var watermarkSize = _watermark!.size
                if watermarkSize.width > renderBounds.width {
                    let aspectRatio = watermarkSize.height / watermarkSize.width
                    let watermarkRenderWidth = renderBounds.width
                    watermarkSize = CGSize(width: watermarkRenderWidth, height: watermarkRenderWidth * aspectRatio)
                }
                
                var watermarkRect = CGRect(x: renderBounds.width - watermarkSize.width, y: renderBounds.height, width: watermarkSize.width, height: watermarkSize.height)
                //If this message is really short we need to shift the watermark over
                if watermarkRect.origin.x < 0 {
                    watermarkRect.offsetInPlace(dx: watermarkRect.origin.x * -1, dy: 0)
                }
                renderBounds.unionInPlace(watermarkRect)
                _watermark?.drawInRect(watermarkRect)
            }
            
            let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
            let cropRect = CGRectMake(renderBounds.origin.x, renderBounds.origin.y, renderBounds.width,     renderBounds.height)
            let croppedImage = CGImageCreateWithImageInRect(renderedImage.CGImage!, cropRect)
        
            return UIImage(CGImage: croppedImage!)
        }
        else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
}
