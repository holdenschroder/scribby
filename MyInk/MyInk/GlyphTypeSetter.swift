import UIKit

class GlyphTypeSetter {
    private let atlas: FontAtlas
    private let fallbackAtlas: FontAtlas
    private let lineHeight: CGFloat
    private let message: Message
    private let margins: UIOffset
    private(set) var placedGlyphs = [PlacedGlyph]()
    private(set) var height: CGFloat = 0
    var width: CGFloat = 1024

    init(message: String, lineHeight: CGFloat, margins: UIOffset, atlases: [FontAtlas]) {
        self.message = Message(string: message)
        self.lineHeight = lineHeight
        self.margins = margins
        self.atlas = atlases.first!
        self.fallbackAtlas = atlases.last!
    }

    func set() {
        placedGlyphs = [PlacedGlyph]()
        height = margins.vertical * 2.0
        var paragraphOffset: UIOffset = margins

        for messageParagraph in message.paragraphs {
            let glyphWords = glyphWordsForMessageParagraph(paragraph: messageParagraph)
            let glyphParagraph = GlyphParagraph(glyphWords: glyphWords, lineHeight: lineHeight, width: width, offset: paragraphOffset)
            placedGlyphs += glyphParagraph.positionedGlyphs
            paragraphOffset.vertical += glyphParagraph.height + lineHeight
            height = paragraphOffset.vertical - lineHeight
        }
    }

    private func glyphWordsForMessageParagraph(paragraph: Paragraph) -> [GlyphWord] {
        var result = [GlyphWord]()
        for word in paragraph.words {
            let glyphs = glyphsForWord(word: word)
            let gw = GlyphWord(glyphs: glyphs, lineHeight: lineHeight)
            result.append(gw)
        }
        return result
    }

    private func glyphsForWord(word: String) -> [FontAtlasGlyph] {
        var result = [FontAtlasGlyph]()
        for character in word.characters {
            let string = String(character)
            if let glyph = atlas.getGlyphData(string) ?? fallbackAtlas.getGlyphData(string) {
                result.append(glyph)
            }
        }
        return result
    }
}

struct PlacedGlyph {
    let glyph: FontAtlasGlyph
    fileprivate(set) var origin = CGPoint.zero

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
}

struct GlyphParagraph {
    let glyphWords: [GlyphWord]
    let lineHeight: CGFloat
    let offset: UIOffset
    let width: CGFloat

    init(glyphWords: [GlyphWord], lineHeight: CGFloat, width: CGFloat, offset: UIOffset) {
        self.glyphWords = glyphWords
        self.lineHeight = lineHeight
        self.width = width
        self.offset = offset
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
        let messageRightMarginX = width - offset.horizontal

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
            wordOffset.horizontal += word.width + word.spacerWidth
        }
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

