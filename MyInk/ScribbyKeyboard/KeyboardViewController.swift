//
//  KeyboardViewController.swift
//  ScribbyKeyboard
//
//  Created by John Lawrence on 1/16/17.
//  Copyright © 2017 E-Link. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    @IBOutlet var nextKeyboardButton: UIButton!

    private var rowCount: Int = 0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutNextKeyboardButton()
        layoutButtons()
    }

    private func layoutNextKeyboardButton() {
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)

        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false

        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        self.view.addSubview(self.nextKeyboardButton)

        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    private func layoutButtons() {
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⇐"] // shifted: ⬆, caps lock ⇪
        let buttonTitles4 = ["🌐", "SPACE", "⏎"]

        let row1 = createRowOfButtons(titles: buttonTitles1)
        let row2 = createRowOfButtons(titles: buttonTitles2)
        let row3 = createRowOfButtons(titles: buttonTitles3)
        let row4 = createRowOfButtons(titles: buttonTitles4)

        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)

        row1.translatesAutoresizingMaskIntoConstraints = false
        row2.translatesAutoresizingMaskIntoConstraints = false
        row3.translatesAutoresizingMaskIntoConstraints = false
        row4.translatesAutoresizingMaskIntoConstraints = false

        addConstraintsToInputView(inputView: self.view, rowViews: [row1, row2, row3, row4])
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

    private func createRowOfButtons(titles: [String]) -> UIView {
        var buttons = [UIButton]()
        let rect = CGRect(x: 0, y: 0, width: 375, height: 50)
        let keyboardRowView = UIView(frame: rect)
        keyboardRowView.tag = rowCount
        rowCount += 1

        for buttonTitle in titles {
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }

        addIndividualButtonConstraints(buttons: buttons, rowView: keyboardRowView)

        return keyboardRowView
    }

    private func createButtonWithTitle(_ title: String) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGray, for: .normal)

        button.addTarget(self, action: #selector(didTapButton(button:)), for: .touchUpInside)

        return button
    }

    @objc func didTapButton(button: UIButton) {
        let proxy = textDocumentProxy as UITextDocumentProxy

        if let title = button.title(for: .normal) as String? {
            switch title {
            case "⇐":
                proxy.deleteBackward()
            case "⏎":
                proxy.insertText("\n")
            case "SPACE":
                proxy.insertText(" ")
            case "🌐":
                self.advanceToNextInputMode()
            case "⇧", "⬆", "⇪":
                break
            default:
                proxy.insertText(title)
            }
//        let buttonTitles3 = ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⇐"] // shifted: ⬆, caps lock ⇪
//        let buttonTitles4 = ["🌐", "SPACE", "⏎"]

        }
    }

    private func addIndividualButtonConstraints(buttons: [UIButton], rowView: UIView){
        for (index, button) in buttons.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .lessThanOrEqual, toItem: rowView, attribute: .top, multiplier: 1.0, constant: 1.0)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: rowView, attribute: .bottom, multiplier: 1.0, constant: -1.0)

            var rightConstraint : NSLayoutConstraint!

            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: rowView, attribute: .right, multiplier: 1.0, constant: 0.0)
            } else {
                let nextButton = buttons[index + 1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -1.0)
            }

            var leftConstraint : NSLayoutConstraint!

            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .lessThanOrEqual, toItem: rowView, attribute: .left, multiplier: 1.0, constant: 0.0)
            } else {
                let prevtButton = buttons[index - 1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevtButton, attribute: .right, multiplier: 1.0, constant: 1.0)

                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0.0)

                widthConstraint.priority = 800.0
                rowView.addConstraint(widthConstraint)
            }

            rowView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }


    private func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        for (index, rowView) in rowViews.enumerated() {
            let rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .right, relatedBy: .equal, toItem: inputView, attribute: .right, multiplier: 1.0, constant: 0.0)
            let leftConstraint = NSLayoutConstraint(item: rowView, attribute: .left, relatedBy: .equal, toItem: inputView, attribute: .left, multiplier: 1.0, constant: 0.0)

            inputView.addConstraints([leftConstraint, rightSideConstraint])

            var topConstraint: NSLayoutConstraint

            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0.0)
            } else {

                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0.0)

                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0.0)

                heightConstraint.priority = 800.0
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)

            var bottomConstraint: NSLayoutConstraint

            if index == (rowViews.count - 1) {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            } else {
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: nextRow, attribute: .top, multiplier: 1.0, constant: 0.0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }

}
