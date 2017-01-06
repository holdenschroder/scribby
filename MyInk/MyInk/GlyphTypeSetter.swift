import UIKit

class GlyphTypeSetter {
    private let atlas: FontAtlas
    private let fallbackAtlas: FontAtlas
    private let lineHeight: CGFloat
    private let maxWidth: CGFloat
    private let message: Message
    private let margins: UIOffset

    private(set) var placedGlyphs = [PlacedGlyph]()
    private var height: CGFloat = 0
    private var width: CGFloat = 0

    init(message: String, lineHeight: CGFloat, maxWidth: CGFloat, margins: UIOffset, atlases: [FontAtlas]) {
        self.message = Message(string: message)
        self.lineHeight = lineHeight
        self.maxWidth = maxWidth
        self.margins = margins
        self.atlas = atlases.first!
        self.fallbackAtlas = atlases.last!
    }

    var size: CGSize {
        return CGSize(width: width, height: height)
    }

    func set() {
        reset()
        var paragraphOffset: UIOffset = margins
        for messageParagraph in message.paragraphs {
            let glyphWords = glyphWordsForMessageParagraph(paragraph: messageParagraph)
            let glyphParagraph = GlyphParagraph(glyphWords: glyphWords, lineHeight: lineHeight, maxWidth: maxWidth, offset: paragraphOffset)
            placedGlyphs += glyphParagraph.positionedGlyphs
            paragraphOffset.vertical += glyphParagraph.height
            print("paragraph height: \(glyphParagraph.height)")
            height = paragraphOffset.vertical
            width = max(width, glyphParagraph.width)
        }
        height += margins.vertical
    }

    private func reset() {
        placedGlyphs = [PlacedGlyph]()
        height = 0
        width = 0
    }

    private func glyphWordsForMessageParagraph(paragraph: Paragraph) -> [GlyphWord] {
        return paragraph.words.map {
            let glyphs = glyphsForWord(word: $0)
            return GlyphWord(glyphs: glyphs, lineHeight: lineHeight)
        }
    }

    private func glyphsForWord(word: String) -> [FontAtlasGlyph] {
        let glyphs: [FontAtlasGlyph?] = word.characters.map {
            let string = String($0)
            return atlas.getGlyphData(string) ?? fallbackAtlas.getGlyphData(string)
        }
        return glyphs.filter {
            return $0 != nil
        } as! [FontAtlasGlyph]
    }
}

struct PlacedGlyph {
    let glyph: FontAtlasGlyph
    fileprivate(set) var origin = CGPoint.zero

    init(glyph: FontAtlasGlyph) {
        self.glyph = glyph
    }

    var bounds: CGRect {
        return glyph.glyphBounds
    }

    var imageCoord: CGRect {
        return glyph.imageCoord
    }

    var image: FontAtlasImage {
        return glyph.image as! FontAtlasImage
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
}

class GlyphParagraph {
    let glyphWords: [GlyphWord]
    let lineHeight: CGFloat
    let offset: UIOffset
    let maxWidth: CGFloat
    private(set) var width: CGFloat = 0
    private(set) var height: CGFloat = 0

    init(glyphWords: [GlyphWord], lineHeight: CGFloat, maxWidth: CGFloat, offset: UIOffset) {
        self.glyphWords = glyphWords
        self.lineHeight = lineHeight
        self.maxWidth = maxWidth
        self.offset = offset
    }

    var positionedGlyphs: [PlacedGlyph] {
        width = 0
        height = 0
        let messageRightMarginX = maxWidth - offset.horizontal

        var result = [PlacedGlyph]()
        var wordOffset = offset
        for word in self.glyphWords {
            if wordOffset.horizontal + word.width > messageRightMarginX {
                wordOffset.horizontal = offset.horizontal
                wordOffset.vertical += self.lineHeight
            }
            for pg in word.placedGlyphsWithOffset(wordOffset) {
                result.append(pg)
            }
            wordOffset.horizontal += word.width
            width = max(width, wordOffset.horizontal)
            wordOffset.horizontal += word.spacerWidth
        }
        width += offset.horizontal
        height = wordOffset.vertical + lineHeight - offset.vertical
        return result
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

struct Paragraph {
    let words: [String]

    init(string: String) {
        self.words = string.components(separatedBy: " ")
    }
}

struct Message {
    let string: String

    init(string: String) {
        self.string = string
    }

    var paragraphs: [Paragraph] {
        let paragraphStrings = string.components(separatedBy: "\n")
        return paragraphStrings.map {
            return Paragraph(string: $0)
        }
    }
}

