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

class KeyboardButton: UIView {
    init(info: KeyboardButtonInfo, delegate: KeyboardButtonDelegate, renderer: FontMessageRenderer?) {
        self.renderer = renderer
        self.delegate = delegate
        self.info = info

        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        createButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var button: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        b.translatesAutoresizingMaskIntoConstraints = true
        b.layer.borderColor = KeyboardViewController.MyInkDarkColor.cgColor
        b.layer.borderWidth = 1.0
        b.layer.cornerRadius = 7
        b.layer.masksToBounds = true
        b.imageView?.contentMode = .scaleAspectFit
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        b.isUserInteractionEnabled = false
        return b
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        setGestureRecognizers()
        button.removeFromSuperview()
        layoutButton()
        addSubview(button)
    }

    var sizeMultiplier: CGFloat = 1
    var horizontalSpacingMultiplier: CGFloat = 1
    let renderer: FontMessageRenderer?
    let delegate: KeyboardButtonDelegate!

    var type: KeyboardButtonType {
        return info.buttonType
    }

    private let info: KeyboardButtonInfo

    private func createButton() {
        var title: String = ""
        let width: CGFloat = 50 * info.widthMultiplier

        sizeMultiplier = info.widthMultiplier

        button.backgroundColor = UIColor(white: 0.8, alpha: 1)
        let buttonBGColor = UIColor(hue: 0.1, saturation: 0.07, brightness: 1, alpha: 1)

        switch info.buttonType {
        case .character(let c):
            title = c
            button.backgroundColor = buttonBGColor
        case .switchToKeyboardTypes(_, let str):
            title = str
        case .space:
            title = "space"
            button.backgroundColor = buttonBGColor
        case .returnOrDone(let str):
            title = str
        case .backspace:
            title = "⌫"
        case .nextKeyboard:
            title = "🌐"
        }

        let margin = UIOffset(horizontal: 0, vertical: 2)
        if let image = renderer?.render(message: title, width: width, lineHeight: 32, backgroundColor: UIColor.clear, maxAspectRatio: nil, alignment: .center, margin: margin) {
            button.setBackgroundImage(image, for: .normal)
            button.setTitleColor(UIColor.clear, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }

    private func setGestureRecognizers() {
        var doubleTap: UITapGestureRecognizer?

        switch info.buttonType {
        case .switchToKeyboardTypes(let keyboardTypes, _):
            if keyboardTypes.count == 2 {
                doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
                doubleTap!.numberOfTapsRequired = 2
                addGestureRecognizer(doubleTap!)
            }
        case .space:
            doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
            doubleTap!.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap!)
        default:
            break
        }

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_:)))
        if let other = doubleTap {
            singleTap.require(toFail: other)
        }
        addGestureRecognizer(singleTap)
    }

    private func layoutButton() {
        var leftIndent: CGFloat = 1
        var rightIndent: CGFloat = 1
        if info.alignment == .right || info.alignment == .left {
            let specialIndent = bounds.width * (sizeMultiplier - 1) / sizeMultiplier
            if info.alignment == .left {
                rightIndent = specialIndent
            } else {
                leftIndent = specialIndent
            }
        }
        button.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 1, left: leftIndent, bottom: 1, right: rightIndent))
    }

    func didSingleTap(_ sender: UIGestureRecognizer) {
        delegate.didSingleTapButton(sender.view as! KeyboardButton)
    }

    func didDoubleTap(_ sender: UIGestureRecognizer) {
        delegate.didDoubleTapButton(sender.view as! KeyboardButton)
    }
    
}
