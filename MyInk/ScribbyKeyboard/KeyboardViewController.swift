//
//  KeyboardViewController.swift
//  ScribbyKeyboard
//
//  Created by John Lawrence on 1/16/17.
//  Copyright © 2017 E-Link. All rights reserved.
//

import UIKit

class KeyboardButton: UIButton {
    var sizeMultiplier: CGFloat = 1
    var horizontalSpacingMultiplier: CGFloat = 1
}

class KeyboardViewController: UIInputViewController {
    private static let buttonSpacing: UIOffset = UIOffset(horizontal: 3.5, vertical: 8.0)
    static let MyInkPinkColor = UIColor(red: 0.93, green: 0, blue: 0.45, alpha: 1.0)
    static let MyInkDarkColor = UIColor(red: 208/255, green: 20/255, blue: 68/255, alpha: 1.0)
    static let MyInkLightColor = UIColor(red: 205/255, green: 23/255, blue: 56/255, alpha: 1.0)


    private lazy var buttonWidthMultiplier: CGFloat = {
        let spacing = KeyboardViewController.buttonSpacing.horizontal * 11
        return (1 - spacing / UIScreen.main.bounds.width) / 10 * 0.98
    }()

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutButtons()
        view.backgroundColor = KeyboardViewController.MyInkPinkColor
    }

    private func layoutButtons() {
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"] // shifted: ⬆, caps lock ⇪
        let buttonTitles4 = ["🌐", "space", "⏎"]

        let row1 = createRowOfButtons(titles: buttonTitles1)
        let row2 = createRowOfButtons(titles: buttonTitles2)
        let row3 = createRowOfButtons(titles: buttonTitles3)
        let row4 = createRowOfButtons(titles: buttonTitles4)

        row1.translatesAutoresizingMaskIntoConstraints = false
        row2.translatesAutoresizingMaskIntoConstraints = false
        row3.translatesAutoresizingMaskIntoConstraints = false
        row4.translatesAutoresizingMaskIntoConstraints = false

        addConstraintsToInputView(inputView: self.view, rowViews: [row1, row2, row3, row4])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(view.bounds)
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        let proxy = self.textDocumentProxy
        let textColor: UIColor = proxy.keyboardAppearance == .dark ? UIColor.white : UIColor.black
    }

    private func createRowOfButtons(titles: [String]) -> UIView {
        var buttons = [KeyboardButton]()
        let rect = CGRect(x: 0, y: 0, width: 375, height: 50)
        let keyboardRowView = UIView(frame: rect)
        view.addSubview(keyboardRowView)

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
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)

        switch title {
        case "⇧", "⬆", "⇪", "⌫", "🌐", "⏎":
            button.sizeMultiplier = 1.4
            button.backgroundColor = UIColor(white: 0.8, alpha: 1)
            button.horizontalSpacingMultiplier = 2.5
        case "space":
            button.sizeMultiplier = 5.5
        default:
            break
        }
        button.layer.borderColor = KeyboardViewController.MyInkDarkColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.darkGray, for: .normal)

        button.addTarget(self, action: #selector(didTapButton(button:)), for: .touchUpInside)

        return button
    }

    @objc func didTapButton(button: UIButton) {
        let proxy = textDocumentProxy as UITextDocumentProxy

        if let title = button.title(for: .normal) as String? {
            switch title {
            case "⌫":
                proxy.deleteBackward()
            case "⏎":
                proxy.insertText("\n")
            case "space":
                proxy.insertText(" ")
            case "🌐":
                self.advanceToNextInputMode()
            case "⇧", "⬆", "⇪":
                break
            default:
                proxy.insertText(title)
            }
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


    private func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        for (index, rowView) in rowViews.enumerated() {
            let widthConstraint = NSLayoutConstraint(item: rowView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: inputView, attribute: .width, multiplier: 1.0, constant: 0)
            let centerConstraint = NSLayoutConstraint(item: rowView, attribute: .centerX, relatedBy: .equal, toItem: inputView, attribute: .centerX, multiplier: 1.0, constant: 0)
            var topConstraint: NSLayoutConstraint

            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0.0)
            } else {
                let prevRow = rowViews[index - 1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0.0)

                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0.0)

                heightConstraint.priority = 800.0
                inputView.addConstraint(heightConstraint)
            }

            inputView.addConstraints([widthConstraint, centerConstraint, topConstraint])

            if index == (rowViews.count - 1) {
                let bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                inputView.addConstraint(bottomConstraint)
            }
        }
        
    }

}
