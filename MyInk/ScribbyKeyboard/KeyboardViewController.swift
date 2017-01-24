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
    private static let buttonSpacing: UIOffset = UIOffset(horizontal: 3.5, vertical: 6.0)
    static let MyInkPinkColor = UIColor(red: 0.93, green: 0, blue: 0.45, alpha: 1.0)
    static let MyInkDarkColor = UIColor(red: 208/255, green: 20/255, blue: 68/255, alpha: 1.0)
    static let MyInkLightColor = UIColor(red: 205/255, green: 23/255, blue: 56/255, alpha: 1.0)
    var heightConstraint: NSLayoutConstraint!

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
        view.backgroundColor = UIColor.clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightConstraint.constant = 216 + 45
    }

    private func layoutButtons() {
        let buttonRowsContainer = UIView(frame: CGRect.zero)
        buttonRowsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonRowsContainer.backgroundColor = KeyboardViewController.MyInkPinkColor
        view.addSubview(buttonRowsContainer)
        let containerWidthConstraint = NSLayoutConstraint(item: buttonRowsContainer, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let containerCenterConstraint = NSLayoutConstraint(item: buttonRowsContainer, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let containerBottomConstraint = NSLayoutConstraint(item: buttonRowsContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let containerHeightConstraint = NSLayoutConstraint(item: buttonRowsContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 216)
        view.addConstraints([containerWidthConstraint, containerCenterConstraint, containerBottomConstraint, containerHeightConstraint])

        heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: UIScreen.main.bounds.height)
        view.addConstraint(heightConstraint)

        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"] // shifted: ⬆, caps lock ⇪
        let buttonTitles4 = ["🌐", "space", "⏎"]

        let row1 = createRowOfButtons(titles: buttonTitles1, inContainer: buttonRowsContainer)
        let row2 = createRowOfButtons(titles: buttonTitles2, inContainer: buttonRowsContainer)
        let row3 = createRowOfButtons(titles: buttonTitles3, inContainer: buttonRowsContainer)
        let row4 = createRowOfButtons(titles: buttonTitles4, inContainer: buttonRowsContainer)

        row1.translatesAutoresizingMaskIntoConstraints = false
        row2.translatesAutoresizingMaskIntoConstraints = false
        row3.translatesAutoresizingMaskIntoConstraints = false
        row4.translatesAutoresizingMaskIntoConstraints = false

        addRowViewConstraints([row1, row2, row3, row4], toContainer: buttonRowsContainer)
    }

//    override func textWillChange(_ textInput: UITextInput?) {
//        // The app is about to change the document's contents. Perform any preparation here.
//    }
//
//    override func textDidChange(_ textInput: UITextInput?) {
//        // The app has just changed the document's contents, the document context has been updated.
//        let proxy = self.textDocumentProxy
//        let textColor: UIColor = proxy.keyboardAppearance == .dark ? UIColor.white : UIColor.black
//    }

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


    private func addRowViewConstraints(_ rowViews: [UIView], toContainer container: UIView) {
        let topButtonConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
        let buttonHeightConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 45)
        let buttonWidthConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let buttonCenterConstraint = NSLayoutConstraint(item: learnSetUpButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        view.addConstraints([topButtonConstraint, buttonHeightConstraint, buttonWidthConstraint, buttonCenterConstraint])

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
        button.setTitle("Scribby setup incomplete. Tap here.", for: .normal)
        button.setTitleColor(KeyboardViewController.MyInkPinkColor, for: .normal)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(setUpButtonTapped(_:)), for: .touchUpInside)
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

    func isAccessGranted() -> Bool {
        let pasteboard: UIPasteboard? = UIPasteboard.general
//        return UIPasteboard.general != nil
        return false
    }

}
