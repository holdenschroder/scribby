import UIKit

enum KeyboardButtonType {
    case character(String)
    case switchToKeyboardTypes([KeyboardType], String)
    case space
    case returnOrDone(String)
    case backspace
    case nextKeyboard
}

protocol KeyboardButtonDelegate: class {
    func didSingleTapButton(_ button: KeyboardButton)
    func didDoubleTapButton(_ button: KeyboardButton)
}

class KeyboardButton: UIButton {
    init(delegate: KeyboardButtonDelegate, renderer: FontMessageRenderer?) {
        self.renderer = renderer
        self.delegate = delegate

        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = KeyboardViewController.MyInkDarkColor.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 7
        layer.masksToBounds = true
        imageView?.contentMode = .scaleAspectFit

        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var sizeMultiplier: CGFloat = 1
    var horizontalSpacingMultiplier: CGFloat = 1
    let renderer: FontMessageRenderer?
    let delegate: KeyboardButtonDelegate!
    var type: KeyboardButtonType = .space {
        didSet {
            var title: String = ""
            var width: CGFloat = 55
            backgroundColor = UIColor(white: 0.8, alpha: 1)

            switch type {
            case .character(let c):
                title = c
                backgroundColor = UIColor.white
            case .switchToKeyboardTypes(_, let str):
                title = str
                width = 80
                sizeMultiplier = 1.4
            case .space:
                title = "space"
                width = 300
                sizeMultiplier = 5.5
                backgroundColor = UIColor.white
            case .returnOrDone(let str):
                title = str
                width = 110
                sizeMultiplier = 2.2
            case .backspace:
                title = "⌫"
                sizeMultiplier = 1.4
            case .nextKeyboard:
                title = "🌐"
                sizeMultiplier = 1.4
            }

            if let image = renderer?.render(message: title, width: width, lineHeight: 35, backgroundColor: UIColor.clear) {
                setBackgroundImage(image, for: .normal)
                setTitleColor(UIColor.clear, for: .normal)
            } else {
                setTitle(title, for: .normal)
                setTitleColor(UIColor.darkGray, for: .normal)
            }

            var doubleTap: UITapGestureRecognizer?

            switch type {
            case .switchToKeyboardTypes(let keyboardTypes, _):
                if keyboardTypes.count == 2 {
                    doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
                    doubleTap!.numberOfTapsRequired = 2
                    addGestureRecognizer(doubleTap!)
                }
            default:
                break
            }

            let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_:)))
            if let other = doubleTap {
                singleTap.require(toFail: other)
            }
            addGestureRecognizer(singleTap)

        }
    }

    func didSingleTap(_ sender: UIGestureRecognizer) {
        delegate.didSingleTapButton(sender.view as! KeyboardButton)
    }

    func didDoubleTap(_ sender: UIGestureRecognizer) {
        delegate.didDoubleTapButton(sender.view as! KeyboardButton)
    }
    
}
