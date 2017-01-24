//
//  KeyboardViewController.swift
//  ScribbyKeyboard
//
//  Created by John Lawrence on 1/16/17.
//  Copyright © 2017 E-Link. All rights reserved.
//

import UIKit

enum KeyboardButtonType {
    case character(String)
    case switchToKeyboardTypes([KeyboardType], String)
    case space
    case returnOrDone(String)
    case backspace
    case nextKeyboard
}

class KeyboardButton: UIButton {
    var sizeMultiplier: CGFloat = 1
    var horizontalSpacingMultiplier: CGFloat = 1
    var isCharacter: Bool = false
    var renderer: FontMessageRenderer?
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
        }
    }

//    func setTitle(_ title: String, withRenderer renderer: FontMessageRenderer?) {
//        setTitle(title, for: .normal)
//
//        let width: CGFloat = title == KeyboardType.spaceString ? 300 : (title.characters.count == 1 ? 55 : 80)
//        if let image = renderer?.render(message: title, width: width, lineHeight: 35, backgroundColor: UIColor.clear) {
//            setBackgroundImage(image, for: .normal)
//            setTitleColor(UIColor.clear, for: .normal)
//        } else {
//            setTitleColor(UIColor.darkGray, for: .normal)
//        }
//    }
}

enum KeyboardType {
    case lower
    case shifted
    case capsLock
    case numeric
    case symbols

    var shiftKeyString: String {
        switch self {
        case .lower:
            return "⇧"
        case .shifted:
            return "⬆"
        case .capsLock:
            return "⇪"
        case .numeric:
            return "#+="
        case .symbols:
            return "123"
        }
    }

    var switchTypeString: String {
        switch self {
        case .numeric, .symbols:
            return "ABC"
        default:
            return "123"
        }
    }

    var characters: [[String]] {
        var result: [[String]]
        switch self {
        case .lower:
            result = KeyboardType.alphaCharacters(shifted: false)
        case .shifted, .capsLock:
            result = KeyboardType.alphaCharacters(shifted: true)
        case .numeric:
            result = [
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                [".", ",", "?", "!", "'"]
            ]
        case .symbols:
            result = [
                ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
                [".", ",", "?", "!", "'"]
            ]
        }
        result[2] = [shiftKeyString] + result[2] + ["⌫"]
        result.append([switchTypeString, "🌐", KeyboardType.spaceString, "⏎"])
        return result
    }

    static let spaceString = "space"

    private static func alphaCharacters(shifted: Bool) -> [[String]] {
        let letters = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]
        if shifted { return letters }
        return letters.map { row in
            return row.map { letter in
                return letter.lowercased()
            }
        }
    }
}

class KeyboardViewController: UIInputViewController {
    private static let buttonSpacing: UIOffset = UIOffset(horizontal: 3.5, vertical: 6.0)
    private static let buttonHeight: CGFloat = 45.0
    private static let keyboardHeight: CGFloat = 216.0
    private var keyboardType: KeyboardType = .lower {
        didSet {
            layoutButtons()
        }
    }

    static let MyInkPinkColor = UIColor(red: 0.93, green: 0, blue: 0.45, alpha: 1.0)
    static let MyInkDarkColor = UIColor(red: 208/255, green: 20/255, blue: 68/255, alpha: 1.0)
    static let MyInkLightColor = UIColor(red: 205/255, green: 23/255, blue: 56/255, alpha: 1.0)

    var messageRenderer: FontMessageRenderer?

    private lazy var buttonWidthMultiplier: CGFloat = {
        let spacing = KeyboardViewController.buttonSpacing.horizontal * 11
        return (1 - spacing / UIScreen.main.bounds.width) / 10 * 0.98
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if isAccessGranted {
            let atlas = FontAtlas.main
            let fallbackAtlas = FontAtlas.fallback
            messageRenderer = FontMessageRenderer(atlas: atlas, fallbackAtlas: fallbackAtlas, watermark: SharedMyInkValues.MyInkWatermark)
            messageRenderer!.margin = UIOffset(horizontal: 0, vertical: 2)
            messageRenderer!.alignment = .center
        }

        layoutButtons()
        view.backgroundColor = UIColor.clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    lazy private var buttonRowsContainer: UIView = {
        let result = UIView(frame: CGRect.zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = KeyboardViewController.MyInkPinkColor
        self.view.addSubview(result)
        let containerWidthConstraint = NSLayoutConstraint(item: result, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let containerCenterConstraint = NSLayoutConstraint(item: result, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let containerHeightConstraint = NSLayoutConstraint(item: result, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: KeyboardViewController.keyboardHeight)
        self.view.addConstraints([containerWidthConstraint, containerCenterConstraint, containerHeightConstraint])

        return result
    }()

    private func layoutButtons() {
        for subview in buttonRowsContainer.subviews {
            subview.removeFromSuperview()
        }
        let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: KeyboardViewController.buttonHeight + KeyboardViewController.keyboardHeight)
        heightConstraint.priority = 999
        view.addConstraint(heightConstraint)

        let rows: [UIView] = keyboardType.characters.map {
            let row = createRowOfButtons(titles: $0, inContainer: buttonRowsContainer)
            row.translatesAutoresizingMaskIntoConstraints = false
            return row
        }

        addRowViewConstraints(rows, toContainer: buttonRowsContainer)
    }

    private func createRowOfButtons(titles: [String], inContainer container: UIView) -> UIView {
        var buttons = [KeyboardButton]()
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let keyboardRowView = UIView(frame: rect)
        keyboardRowView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(keyboardRowView)

        for buttonTitle in titles {
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }

        addIndividualButtonConstraints(buttons: buttons, rowView: keyboardRowView)

        return keyboardRowView
    }

    private func createButtonWithTitle(_ title: String) -> KeyboardButton {
        let button = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.renderer = messageRenderer

        switch title {
        case "⇧":
            button.type = .switchToKeyboardTypes([.shifted, .capsLock], title)
        case "⬆":
            button.type = .switchToKeyboardTypes([.lower, .capsLock], title)
        case "⇪":
            button.type = .switchToKeyboardTypes([.lower], title)
        case "⌫":
            button.type = .backspace
        case "🌐":
            button.type = .nextKeyboard
        case "⏎":
            button.type = .returnOrDone("return")
        case "123":
            button.type = .switchToKeyboardTypes([.numeric], title)
        case "ABC":
            button.type = .switchToKeyboardTypes([.lower], title)
        case "#+=":
            button.type = .switchToKeyboardTypes([.symbols], title)
        case KeyboardType.spaceString:
            button.type = .space
        default:
            button.isCharacter = true
            button.type = .character(title)
        }
        button.layer.borderColor = KeyboardViewController.MyInkDarkColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit

        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false

        var doubleTap: UITapGestureRecognizer?

        switch button.type {
        case .switchToKeyboardTypes(let keyboardTypes, _):
            if keyboardTypes.count == 2 {
                doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapButton(_:)))
                doubleTap!.numberOfTapsRequired = 2
                button.addGestureRecognizer(doubleTap!)
            }
        default:
            break
        }

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTapShiftButton(_:)))
        if let other = doubleTap {
            singleTap.require(toFail: other)
        }
        button.addGestureRecognizer(singleTap)

        return button
    }

    @objc func didDoubleTapButton(_ recognizer: UITapGestureRecognizer) {
        keyboardType = .capsLock
    }

    @objc func didSingleTapShiftButton(_ recognizer: UITapGestureRecognizer) {
        let button = recognizer.view as! KeyboardButton
        let proxy = textDocumentProxy as UITextDocumentProxy

        switch button.type {
        case .character(let c):
            proxy.insertText(c)
            if keyboardType == .shifted {
                keyboardType = .lower
            }
        case .backspace:
            proxy.deleteBackward()
        case .nextKeyboard:
            advanceToNextInputMode()
        case .returnOrDone(_):
            proxy.insertText("\n")
        case .space:
            proxy.insertText(" ")
        case .switchToKeyboardTypes(let keyboardTypes, _):
            keyboardType = keyboardTypes.first!
        }
    }

    private func addIndividualButtonConstraints(buttons: [KeyboardButton], rowView: UIView){
        for (index, button) in buttons.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .lessThanOrEqual, toItem: rowView, attribute: .top, multiplier: 1.0, constant: KeyboardViewController.buttonSpacing.vertical / 2.0)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: rowView, attribute: .bottom, multiplier: 1.0, constant: -KeyboardViewController.buttonSpacing.vertical / 2.0)

            if index == buttons.count - 1 {
                let rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: rowView, attribute: .right, multiplier: 1.0, constant: -KeyboardViewController.buttonSpacing.horizontal)
                rowView.addConstraint(rightConstraint)
            }

            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: rowView, attribute: .left, multiplier: 1.0, constant: KeyboardViewController.buttonSpacing.horizontal)
            } else {
                let prevButton = buttons[index - 1]
                let widthSeparator = max(button.horizontalSpacingMultiplier, prevButton.horizontalSpacingMultiplier) * KeyboardViewController.buttonSpacing.horizontal
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: .right, multiplier: 1.0, constant: widthSeparator)
            }
            let widthMultiplier = buttonWidthMultiplier * button.sizeMultiplier
            let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: widthMultiplier, constant: 0)

            widthConstraint.priority = 800.0
            view.addConstraint(widthConstraint)

            rowView.addConstraints([topConstraint, bottomConstraint, leftConstraint])
        }
    }

    private func addRowViewConstraints(_ rowViews: [UIView], toContainer container: UIView) {
        let topButtonConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomButtonConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
        let buttonHeightConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: KeyboardViewController.buttonHeight)
        let buttonWidthConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let buttonCenterConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        view.addConstraints([topButtonConstraint, bottomButtonConstraint, buttonHeightConstraint, buttonWidthConstraint, buttonCenterConstraint])

        for (index, rowView) in rowViews.enumerated() {
            let widthConstraint = NSLayoutConstraint(item: rowView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: container, attribute: .width, multiplier: 1.0, constant: 0)
            let centerConstraint = NSLayoutConstraint(item: rowView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0)
            var topConstraint: NSLayoutConstraint


            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
            } else {
                let prevRow = rowViews[index - 1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0.0)

                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0.0)

                heightConstraint.priority = 800.0
                container.addConstraint(heightConstraint)
            }

            container.addConstraints([widthConstraint, centerConstraint, topConstraint])

            if index == (rowViews.count - 1) {
                let bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                container.addConstraint(bottomConstraint)
            }
        }
        
    }

    private lazy var learnSetUpButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(self.isAccessGranted ? "" : "Scribby setup incomplete. Tap here.", for: .normal)
        button.setTitleColor(KeyboardViewController.MyInkPinkColor, for: .normal)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        if !self.isAccessGranted {
            button.addTarget(self, action: #selector(setUpButtonTapped(_:)), for: .touchUpInside)
        }
        self.inputView?.addSubview(button)
        return button
    }()

    func setUpButtonTapped(_ button: UIButton) {
        let url = NSURL(string: "scribbyapp://tutorials/keyboard")
        let context = NSExtensionContext()
        context.open(url! as URL, completionHandler: nil)

        var responder = self as UIResponder?

        while (responder != nil){
            if responder?.responds(to: Selector("openURL:")) == true {
                _ = responder?.perform(Selector("openURL:"), with: url)
            }
            responder = responder!.next
        }
    }

    var isAccessGranted: Bool {
        let originalString = UIPasteboard.general.string
        UIPasteboard.general.string = "TEST"
        if UIPasteboard.general.hasStrings {
            UIPasteboard.general.string = originalString
            return true
        } else {
            return false
        }
    }

}
