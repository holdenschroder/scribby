import UIKit

class FontMessageRenderer
{
    static let beige = UIColor(hue: 0.05, saturation: 0.1, brightness: 1, alpha: 1)
    fileprivate var _atlas: FontAtlas
    fileprivate var _fallbackAtlas: FontAtlas

    init(atlas: FontAtlas, fallbackAtlas: FontAtlas, watermark: UIImage?) {
        _atlas = atlas
        _fallbackAtlas = fallbackAtlas
    }

    func render(message: String, width: CGFloat, lineHeight: CGFloat, backgroundColor: UIColor, maxAspectRatio: CGFloat? = nil, alignment: TypeSetterAlignment = .left, margin: UIOffset = UIOffset(horizontal: 25, vertical: 25)) -> UIImage? {

        let typeSetter = TypeSetter(message: message, lineHeight: lineHeight, width: width, kerning: 0.1, atlases: [_atlas, _fallbackAtlas], maxAspectRatio: maxAspectRatio ?? CGFloat.greatestFiniteMagnitude)
        typeSetter.margin = margin
        typeSetter.set(alignment: alignment)

        let size = typeSetter.size

        guard size.width != 0 && !typeSetter.isEmpty else {
            return nil
        }

        UIGraphicsBeginImageContext(size)
        let graphicsContext = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        graphicsContext!.fill(CGRect(origin: CGPoint.zero, size: size))

        for placedGlyph in typeSetter.placedGlyphs {
            let imageData = placedGlyph.image
            let subImage = UIImage(cgImage: imageData.loadedImage!.cgImage!.cropping(to: placedGlyph.imageCoord * imageData.loadedImage!.size)!)
            subImage.draw(in: placedGlyph.rect)
        }

        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return renderedImage
    }
}
