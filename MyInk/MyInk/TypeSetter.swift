import UIKit

enum TypeSetterAlignment {
    case left, center
}

class TypeSetter {
    static let lineSpacing: CGFloat = 0.2
    private let message: Message
    private let lineHeight: CGFloat
    private let width: CGFloat
    private let kerning: CGFloat
    private let atlas: FontAtlas
    private let fallbackAtlas: FontAtlas
    private let maxAspectRatio: CGFloat
    private var _glyphLines: [GlyphLine]?
    private(set) var placedGlyphs = [PlacedGlyph]()

    var glyphLines: [GlyphLine] {
        if _glyphLines == nil {
            recalculateGlyphLines()
        }
        return _glyphLines!
    }

    var margin = UIOffset.zero {
        didSet {
            if oldValue.horizontal != margin.horizontal {
                recalculateGlyphLines()
            }
        }
    }

    init(message: String, lineHeight: CGFloat, width: CGFloat, kerning: CGFloat, atlases: [FontAtlas], maxAspectRatio: CGFloat) {
        self.message = Message(string: message)
        self.lineHeight = lineHeight
        self.width = width
        self.kerning = kerning
        self.atlas = atlases.first!
        self.fallbackAtlas = atlases.last!
        self.maxAspectRatio = maxAspectRatio > 0 ? maxAspectRatio : CGFloat.greatestFiniteMagnitude
    }

    var height: CGFloat {
        let heightOfLines = CGFloat(glyphLines.count) * lineHeight * (1 + TypeSetter.lineSpacing)
        return heightOfLines + lineHeight * 0.2 + margin.vertical * 2
    }

    var size: CGSize {
        return CGSize(width: width, height: height)
    }

    var aspectRatio: CGFloat {
        return width / height
    }

    var isEmpty: Bool {
        return glyphLines.count == 0 || glyphLines.first!.width == 0
    }

    func set(alignment: TypeSetterAlignment = .left, centerSmallMessages: Bool = true) {
        var alignment = alignment

        while aspectRatio > maxAspectRatio {
            if centerSmallMessages {
                alignment = .center
            }
            margin.vertical += 10
        }

        let perLineOffset = lineHeight * (1 + TypeSetter.lineSpacing)
        placedGlyphs = [PlacedGlyph]()
        var glyphOffset = UIOffset(horizontal: 0, vertical: margin.vertical)
        for line in glyphLines {
            glyphOffset.horizontal = indentation(lineWidth: line.width, alignment: alignment)
            for word in line.words {
                for placedGlyph in word.glyphs {
                    placedGlyphs.append(PlacedGlyph(glyph: placedGlyph.glyph, rect: placedGlyph.rect.offsetBy(dx: glyphOffset.horizontal, dy: glyphOffset.vertical)))
                }
                glyphOffset.horizontal += wordSpacing + word.width
            }
            glyphOffset.vertical += perLineOffset
        }

    }

    private func indentation(lineWidth: CGFloat, alignment: TypeSetterAlignment) -> CGFloat {
        switch alignment {
        case .left:
            return margin.horizontal
        case .center:
            return (width - lineWidth) / 2.0
        }
    }

    // A GlyphParagraph simply contains all of the words without any information concerning layout
    //    of words on the page. Changing the horizontal margin, although it changes the number of
    //    words per line, will never affect the glyph placement within the word, hence the
    //    memoization here.
    private lazy var glyphParagraphs: [GlyphParagraph] = {
        return self.message.paragraphs.map {
            return self.glyphParagraphFromParagraph($0)
        }
    }()

    private lazy var wordSpacing: CGFloat = {
        return self.kerning * self.lineHeight * 4
    }()

    private func recalculateGlyphLines() {
        let maxWidth = width - margin.horizontal * 2
        _glyphLines = glyphParagraphs.map {
            return glyphLinesFromGlyphParagraph($0, maxWidth: maxWidth)
        }.flatMap { $0 }
    }

    private func glyphLinesFromGlyphParagraph(_ paragraph: GlyphParagraph, maxWidth: CGFloat) -> [GlyphLine] {
        guard paragraph.words.count > 0 else { return [GlyphLine.zero] }
        var result = [GlyphLine]()
        var glyphWords = [GlyphWord]()
        var lineWidth: CGFloat = 0
        for glyphWord in paragraph.words {
            let lineWidthWithNextWord = lineWidth + glyphWord.width
            if lineWidthWithNextWord > maxWidth {
                result.append(GlyphLine(glyphWords: glyphWords, wordSpacing: wordSpacing))
                lineWidth = 0
                glyphWords = []
            }
            glyphWords.append(glyphWord)
            lineWidth += glyphWord.width + wordSpacing
        }
        if glyphWords.count > 0 {
            result.append(GlyphLine(glyphWords: glyphWords, wordSpacing: wordSpacing))
        }
        return result
    }

    private func glyphsForString(_ string: String) -> [FontAtlasGlyph] {
        guard !string.isEmpty else { return [] }

        let glyphs: [FontAtlasGlyph?] = string.characters.map {
            let string = String($0)
            return atlas.getGlyphData(string) ?? fallbackAtlas.getGlyphData(string)
        }
        return glyphs.filter {
            return $0 != nil
        } as! [FontAtlasGlyph]
    }

    private func glyphParagraphFromParagraph(_ paragraph: Paragraph) -> GlyphParagraph {
        let glyphWords: [GlyphWord] = paragraph.words.map {
            let glyphs = glyphsForString($0)
            return glyphWordWithGlyphs(glyphs)
        }
        return GlyphParagraph(glyphWords: glyphWords)
    }

    private func glyphWordWithGlyphs(_ glyphs: [FontAtlasGlyph]) -> GlyphWord {
        let size = CGSize(width: lineHeight, height: lineHeight)
        var placedGlyphs = [PlacedGlyph]()
        var originX: CGFloat = 0

        for glyph in glyphs {
            let origin = CGPoint(x: originX - glyph.glyphBounds.origin.x, y: glyph.glyphBounds.origin.y) * lineHeight
            let pg = PlacedGlyph(glyph: glyph, rect: CGRect(origin: origin, size: size))
            placedGlyphs.append(pg)

            originX += glyph.glyphBounds.width + kerning
        }

        return GlyphWord(glyphs: placedGlyphs)
    }

}

struct PlacedGlyph {
    let glyph: FontAtlasGlyph
    let rect: CGRect

    init(glyph: FontAtlasGlyph, rect: CGRect) {
        self.glyph = glyph
        self.rect = rect
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

struct GlyphLine {
    static var zero: GlyphLine {
        return GlyphLine(glyphWords: [], wordSpacing: 0)
    }

    let words: [GlyphWord]
    let wordSpacing: CGFloat
    private(set) var width: CGFloat = 0

    init(glyphWords: [GlyphWord], wordSpacing: CGFloat) {
        self.words = glyphWords
        self.wordSpacing = wordSpacing
        if glyphWords.count > 0 {
            let wordWidths = glyphWords.map {
                $0.width
            }.reduce(0, +)
            self.width = wordWidths + wordSpacing * CGFloat(glyphWords.count - 1)
        }
    }
}

struct GlyphParagraph {
    let words: [GlyphWord]

    init(glyphWords: [GlyphWord]) {
        self.words = glyphWords
    }
}

struct GlyphWord {
    let glyphs: [PlacedGlyph]
    let width: CGFloat

    init(glyphs: [PlacedGlyph]) {
        self.glyphs = glyphs
        self.width = glyphs.count == 0 ? 0 : glyphs.last!.rect.maxX
    }
}

struct Paragraph {
    private let _words: [String]

    init(string: String) {
        self._words = string.components(separatedBy: " ")
    }

    var words: [String] {
        return _words.filter {
            return !$0.isEmpty
        }
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
