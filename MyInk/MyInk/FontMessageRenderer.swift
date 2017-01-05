import UIKit

struct PlacedGlyph {
    let glyph: FontAtlasGlyph
    fileprivate var origin = CGPoint.zero

    init(glyph: FontAtlasGlyph) {
        self.glyph = glyph
    }
}

class GlyphWord {
    static let characterSpacing: CGFloat = 0.1
    static let wordSpacing: CGFloat = 0.4
    fileprivate var origin: CGPoint = CGPoint.zero
    let glyphs: [FontAtlasGlyph]
    let characterSize: CGSize

    init(glyphs: [FontAtlasGlyph], lineHeight: CGFloat) {
        self.glyphs = glyphs
        self.characterSize = CGSize(width: lineHeight, height: lineHeight)
    }

    private(set) lazy var width: CGFloat = {
        let spacersWidth = type(of: self).characterSpacing * (self.glyphs.count - 1)
        return self.characterSize.width * self.glyphs.reduce(spacersWidth) { $0 + $1.glyphBounds.width }
    }()

    private(set) lazy var spacerWidth: CGFloat = {
        return type(of: self).wordSpacing * self.characterSize.width
    }()

    private lazy var characterCount: Int = {
        return self.glyphs.count
    }()

    private(set) lazy var placedGlyphs: [PlacedGlyph] = {
        var result = [PlacedGlyph]()
        var originX: CGFloat = 0

        for glyph in self.glyphs {
            var pg = PlacedGlyph(glyph: glyph)
            pg.origin = CGPoint(x: originX - glyph.glyphBounds.origin.x, y: glyph.glyphBounds.origin.y) * self.characterSize.width
            result.append(pg)

            originX += glyph.glyphBounds.width + type(of: self).characterSpacing
        }
        return result
    }()

    func placedGlyphsWithOffset(_ offset: UIOffset) -> [PlacedGlyph] {
        var result = [PlacedGlyph]()
        var originX: CGFloat = 0

        for glyph in self.glyphs {
            var pg = PlacedGlyph(glyph: glyph)
            pg.origin = CGPoint(x: originX - glyph.glyphBounds.origin.x, y: glyph.glyphBounds.origin.y) * self.characterSize.width
            pg.origin += offset
            result.append(pg)

            originX += glyph.glyphBounds.width + type(of: self).characterSpacing
        }
        return result
    }

    //    private(set) lazy var size: CGSize = {
    //        var result = self._placedGlyphs[0].rect
    //        for glyph in Array(self._placedGlyphs[1..<self.characterCount]) {
    //            result = result.union(glyph.rect)
    //        }
    //        return result.size
    //    }()

    //    func placedGlyphs(offsetBy: UIOffset?) -> [PlacedGlyph] {
    //        let offset = offsetBy ?? UIOffset.zero
    //        return _placedGlyphs.map {
    //            let rect = $0.rect.offsetBy(dx: offset.horizontal, dy: offset.vertical)
    //            return PlacedGlyph(rect: rect, glyph: $0.glyph)
    //        }
    //    }
}

class GlyphParagraph {
    let glyphWords: [GlyphWord]
    let lineHeight: CGFloat
    var width: CGFloat = 0 {
        didSet {
            _positionedGlyphs = nil
        }
    }
    private var _positionedGlyphs: [PlacedGlyph]?

    init(glyphWords: [GlyphWord], lineHeight: CGFloat, horizontalMargin: CGFloat, verticalOrigin: CGFloat) {
        self.glyphWords = glyphWords
        self.lineHeight = lineHeight
    }

    var height: CGFloat {
        if let glyph = positionedGlyphs.last {
            return glyph.origin.y + lineHeight
        }
        return 0
    }

    var aspectRatio: CGFloat? {
        guard height > 0 else {
            return CGFloat.greatestFiniteMagnitude
        }
        return width / height
    }

    var positionedGlyphs: [PlacedGlyph] {
        if _positionedGlyphs == nil {
            _positionedGlyphs = [PlacedGlyph]()
            var wordOffset = UIOffset.zero
            for word in self.glyphWords {
                if wordOffset.horizontal + word.width > width { //- self.horizontalMargin {
                    wordOffset.horizontal = 0 //self.horizontalMargin
                    wordOffset.vertical += self.lineHeight
                }
                for pg in word.placedGlyphsWithOffset(wordOffset) {
                    _positionedGlyphs!.append(pg)
                }
                wordOffset.horizontal += word.width + word.spacerWidth
            }
        }
        return _positionedGlyphs!
    }

    var maxWordWidth: CGFloat {
        guard glyphWords.count > 0 else {
            return 0
        }
        return glyphWords.max(by: {
            $0.width < $1.width
        })!.width
    }
}

class FontMessageRenderer
{
    static let beige = UIColor(hue: 0.05, saturation: 0.1, brightness: 1, alpha: 1)
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

    func render(message: String, maxWidth: CGFloat, lineHeight: CGFloat, backgroundColor: UIColor, minAspectRatio: CGFloat? = nil) -> UIImage? {
        let lines = message.components(separatedBy: "\n")
        let paragraphs = glyphParagraphsFromLines(lines, lineHeight: lineHeight)

        let maxWordWidth: CGFloat = paragraphs.max(by: { $0.maxWordWidth < $1.maxWordWidth })?.maxWordWidth ?? maxWidth

        let paragraph = paragraphs[0]
        paragraph.width = maxWordWidth * 2

        let imageSize = CGSize(width: paragraph.width + _margins.x * 2, height: paragraph.height + _margins.y * 2)
        UIGraphicsBeginImageContext(imageSize)
        let graphicsContext = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        graphicsContext!.fill(CGRect(origin: CGPoint.zero, size: imageSize))

        for character in paragraph.positionedGlyphs {
            let imageData = character.glyph.image as! FontAtlasImage
            let subImage = UIImage(cgImage: imageData.loadedImage!.cgImage!.cropping(to: character.glyph.imageCoord * imageData.loadedImage!.size)!)
            let characterSize = CGSize(width: lineHeight, height: lineHeight) // character.glyph.glyphBounds.size * lineHeight
            let rect = CGRect(origin: character.origin, size: characterSize).offsetBy(dx: _margins.x, dy: _margins.y)
            subImage.draw(in: rect)
        }
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return renderedImage
    }

    private func glyphParagraphsFromLines(_ lines: [String], lineHeight: CGFloat) -> [GlyphParagraph] {
        var result = [GlyphParagraph]()
        for line in lines {
            var glyphWords: [GlyphWord] = []
            let words = line.components(separatedBy: " ")

            for word in words {
                let gw = glyphWord(word: word, lineHeight: lineHeight)
                glyphWords.append(gw)
            }
            result.append(GlyphParagraph(glyphWords: glyphWords, lineHeight: lineHeight, horizontalMargin: _margins.x, verticalOrigin: 0))
        }
        return result
    }

    private func glyphWord(word: String, lineHeight: CGFloat) -> GlyphWord {
        var glyphs = [FontAtlasGlyph]()
        for character in word.characters {
            let characterString = String(character)
            if let glyphData = _atlas.getGlyphData(characterString) ?? _fallbackAtlas.getGlyphData(characterString) {
                glyphs.append(glyphData)
            }
        }
        return GlyphWord(glyphs: glyphs, lineHeight: lineHeight)
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
                    print("Word: '\(word)', here because caret posX \(caretPosition.origin.x) + wordWidth \(wordWidth) > maxWdith \(maxWidth) - 2Xmargin \(_margins.x * 2)")
                    numRenderedLines += 1
                }

                for (i, glyphData) in glyphs.enumerated() {
                    //                    print("Rendering character '\(word[word.index(word.startIndex, offsetBy: i)])'")
                    let imageData = glyphData.image as! FontAtlasImage
                    let subImage = UIImage(cgImage: imageData.loadedImage!.cgImage!.cropping(to: glyphData.imageCoord * imageData.loadedImage!.size)!);

                    UIColor.white.setFill()
                    var characterRect = glyphData.glyphBounds
                    characterRect = characterRect * caretPosition.size
                    let renderPosition = caretPosition.offsetBy(dx: -characterRect.origin.x, dy: characterRect.origin.y)
                    print("render position: \(renderPosition)")
                    if showDebugInfo {
                        var debugRect = characterRect
                        debugRect.origin += CGPoint(x: renderPosition.origin.x, y: renderPosition.origin.y)
                        graphicsContext!.fill(debugRect)
                    }
                    //                    print("Bounds before union: \(renderBounds), New Position: \(renderPosition)")
                    renderBounds = renderBounds.union(renderPosition)
                    //                    print("Bounds  after union: \(renderBounds)\n")
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
            //            print("Cropped rect      : \(cropRect)")
            //            print("Image width: \(imageSize.width)")
            //            print("Aspect Ratio: \(aspectRatio)\n\n**************************\n")
            //            print("Number of lines: \(numRenderedLines)")
            return render(message: message, maxWidth: 1024, lineHeight: lineHeight, backgroundColor: backgroundColor)

            // 1.25
            //            if shouldEnforceAspectRatio && aspectRatio > 1.25 && numRenderedLines < numRenderedWords {
            //                croppedImage = nil
            //                renderedImage = nil
            //                return renderMessage(message, imageSize: CGSize(width: imageSize.width, height: 1024), lineHeight: lineHeight, backgroundColor: backgroundColor, showDebugInfo: showDebugInfo, maxLineWidth: maxWidth * 0.67)
            //            }
            
            return UIImage(cgImage: croppedImage!)
        }
        else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
}
