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

    func render(message: String, width: CGFloat, lineHeight: CGFloat, backgroundColor: UIColor, maxAspectRatio: CGFloat = CGFloat.greatestFiniteMagnitude) -> UIImage? {
        let typeSetter = TypeSetter(message: message, lineHeight: lineHeight, width: width, kerning: 0.1, atlases: [_atlas, _fallbackAtlas], maxAspectRatio: maxAspectRatio)
        typeSetter.margin = UIOffset(horizontal: 25, vertical: 25)
        typeSetter.set()

        let size = typeSetter.size
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

    func renderMessage(_ message: String, imageSize: CGSize, lineHeight: CGFloat, backgroundColor: UIColor, showDebugInfo: Bool = false, maxLineWidth: CGFloat? = nil) -> UIImage? {
        return render(message: message, width: 750, lineHeight: lineHeight, backgroundColor: backgroundColor, maxAspectRatio: 1.75)
    }
}
