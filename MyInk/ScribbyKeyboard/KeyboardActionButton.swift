import UIKit

@IBDesignable
class KeyboardActionButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        setTitleColor(KeyboardViewController.MyInkDarkColor, for: .normal)
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 5
        layer.borderColor = KeyboardViewController.MyInkDarkColor.cgColor
        layer.borderWidth = 1.5
        layer.masksToBounds = true
    }
}

@IBDesignable
class MessageDisplayScrollView: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 5
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        layer.masksToBounds = true
    }
}
