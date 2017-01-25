//
//  KeyboardViewController.swift
//  ScribbyKeyboard
//
//  Created by John Lawrence on 1/16/17.
//  Copyright © 2017 E-Link. All rights reserved.
//

import UIKit


class KeyboardViewController: UIInputViewController {
    private static let buttonSpacing: UIOffset = UIOffset(horizontal: 3.5, vertical: 6.0)
    private static let buttonHeight: CGFloat = 45.0
    private static let keyboardHeight: CGFloat = 216.0
    fileprivate var keyboardType: KeyboardType = .lower {
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

        let rows: [UIView] = keyboardType.buttonTypes.map {
            let row = createRowOfButtons(types: $0, inContainer: buttonRowsContainer)
            row.translatesAutoresizingMaskIntoConstraints = false
            return row
        }

        addRowViewConstraints(rows, toContainer: buttonRowsContainer)
    }

    private func createRowOfButtons(types: [KeyboardButtonType], inContainer container: UIView) -> UIView {
        var buttons = [KeyboardButton]()
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let keyboardRowView = UIView(frame: rect)
        keyboardRowView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(keyboardRowView)

        for buttonType in types {
            let button = createButtonWithType(buttonType)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }

        addIndividualButtonConstraints(buttons: buttons, rowView: keyboardRowView)

        return keyboardRowView
    }

    private func createButtonWithType(_ type: KeyboardButtonType) -> KeyboardButton {
        let button = KeyboardButton(delegate: self, renderer: messageRenderer)
        button.type = type
        return button
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

extension KeyboardViewController: KeyboardButtonDelegate {
    func didSingleTapButton(_ button: KeyboardButton) {
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

    func didDoubleTapButton(_ button: KeyboardButton) {
        keyboardType = .capsLock
    }
}

