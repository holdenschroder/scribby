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
    private static let buttonHeight: CGFloat = 55.0
    private static let keyboardHeight: CGFloat = 216.0

    fileprivate var _keyboardType: KeyboardType = .shifted

    func setKeyboardType(_ type: KeyboardType, forceRedraw: Bool = false) {
        let oldType = _keyboardType
        _keyboardType = type
        if type != oldType || forceRedraw {
            layoutButtons()
        }
    }
    var keyboardType: KeyboardType { return _keyboardType }

    fileprivate var message: String = ""
    private var topButtonHeightConstraint: NSLayoutConstraint!
    private var totalHeightConstraint: NSLayoutConstraint!

    static let MyInkPinkColor = UIColor(red: 0.93, green: 0, blue: 0.45, alpha: 1.0)
    static let MyInkDarkColor = UIColor(red: 208/255, green: 20/255, blue: 68/255, alpha: 1.0)
    static let MyInkLightColor = UIColor(red: 205/255, green: 23/255, blue: 56/255, alpha: 1.0)

    var messageRenderer: FontMessageRenderer?
    fileprivate var messagePreviewView: MessageDisplayView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isAccessGranted {
            messageRenderer = FontMessageRenderer(atlas: FontAtlas.main, fallbackAtlas: FontAtlas.fallback, watermark: SharedMyInkValues.MyInkWatermark)
        }
        setKeyboardType(textDocumentProxy.autocapitalizationType == UITextAutocapitalizationType.none ? .lower : .shifted, forceRedraw: true)

        if isAccessGranted {
            topBannerButton.setTitle(calledFromScribbyApp ? "" : "Scribbify message!", for: .normal)
        } else {
            topBannerButton.setTitle("Scribby setup incomplete. Tap here.", for: .normal)
        }
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
        if totalHeightConstraint == nil {
            totalHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 9)
            totalHeightConstraint.priority = 999
            view.addConstraint(totalHeightConstraint)
        }
        totalHeightConstraint.constant = KeyboardViewController.keyboardHeight + (calledFromScribbyApp ? 0 : KeyboardViewController.buttonHeight)


        let rows: [UIView] = keyboardType.buttonInfos(returnKeyType: textDocumentProxy.returnKeyType).map {
            let row = createRowOfButtons(infos: $0, inContainer: buttonRowsContainer)
            row.translatesAutoresizingMaskIntoConstraints = false
            return row
        }

        addRowViewConstraints(rows, toContainer: buttonRowsContainer)
    }

    private func createRowOfButtons(infos: [KeyboardButtonInfo], inContainer container: UIView) -> UIView {
        var buttons = [KeyboardButton]()
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let keyboardRowView = UIView(frame: rect)
        keyboardRowView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(keyboardRowView)

        for buttonInfo in infos {
            let button = createButtonWithInfo(buttonInfo)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }

        addIndividualButtonConstraints(buttons: buttons, rowView: keyboardRowView)

        return keyboardRowView
    }

    private func createButtonWithInfo(_ info: KeyboardButtonInfo) -> KeyboardButton {
        return KeyboardButton(info: info, delegate: self, renderer: messageRenderer)
    }

    private func addIndividualButtonConstraints(buttons: [KeyboardButton], rowView: UIView){
        for (index, button) in buttons.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: rowView, attribute: .top, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: rowView, attribute: .bottom, multiplier: 1.0, constant: 0)

            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: rowView, attribute: .left, multiplier: 1.0, constant: 0)
            } else {
                let prevButton = buttons[index - 1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: .right, multiplier: 1.0, constant: 0)
            }

            if index == buttons.count - 1 {
                let rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: rowView, attribute: .right, multiplier: 1.0, constant: 0)
                rowView.addConstraint(rightConstraint)
            }

            let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: rowView, attribute: .width, multiplier: 0.1 * button.sizeMultiplier, constant: 0)
            widthConstraint.priority = 800.0

            rowView.addConstraints([topConstraint, bottomConstraint, leftConstraint, widthConstraint])
        }
    }

    private func addRowViewConstraints(_ rowViews: [UIView], toContainer container: UIView) {
        let buttonHeight = calledFromScribbyApp && isAccessGranted ? 0 : KeyboardViewController.buttonHeight

        let topButtonConstraint = NSLayoutConstraint(item: topBannerButton, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomButtonConstraint = NSLayoutConstraint(item: topBannerButton, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
        topButtonHeightConstraint = NSLayoutConstraint(item: topBannerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: buttonHeight)
        let buttonWidthConstraint = NSLayoutConstraint(item: topBannerButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let buttonCenterConstraint = NSLayoutConstraint(item: topBannerButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        view.addConstraints([topButtonConstraint, bottomButtonConstraint, topButtonHeightConstraint, buttonWidthConstraint, buttonCenterConstraint])

        for (index, rowView) in rowViews.enumerated() {
            let widthConstraint = NSLayoutConstraint(item: rowView, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.99, constant: 0)
            let centerConstraint = NSLayoutConstraint(item: rowView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0)
            var topConstraint: NSLayoutConstraint


            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 2.0)
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
                let bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: -2.0)
                container.addConstraint(bottomConstraint)
            }
        }
        
    }

    var calledFromScribbyApp: Bool {
        guard isAccessGranted else { return false }
        if let contentType = textDocumentProxy.textContentType {
            return contentType == UITextContentType.scribbyInput
        }
        return false
    }

    private lazy var topBannerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(KeyboardViewController.MyInkPinkColor, for: .normal)
        button.backgroundColor = UIColor(white: 0.1, alpha: 1)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: self.isAccessGranted ? 21 : 17)
        button.addTarget(self, action: #selector(setUpButtonTapped(_:)), for: .touchUpInside)
        self.inputView?.addSubview(button)
        return button
    }()

    private lazy var successLabel: UILabel = {
        let label = UILabel(frame: self.topBannerButton.bounds)
        label.backgroundColor = UIColor(white: 0.1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = KeyboardViewController.MyInkPinkColor
        label.textAlignment = .center
        label.text = "Message copied to clipboard. Now paste!"
        return label
    }()

    fileprivate func hoistSuccessLabel() {
        successLabel.alpha = 1
        topBannerButton.addSubview(successLabel)

        UIView.animate(withDuration: 5.0, animations: {
            self.successLabel.alpha = 0
        }, completion: { _ in
            self.successLabel.removeFromSuperview()
        })
    }

    func setUpButtonTapped(_ button: UIButton) {
        if isAccessGranted {
            let textProxyConsumer = TextProxyConsumer()
            textProxyConsumer.consume(proxy: textDocumentProxy, onCompleteEvent: handleRenderingOfMessage)
        } else {
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
    }

    func handleRenderingOfMessage(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        self.message = message
        let image = messageRenderer?.render(message: message, width: 750, lineHeight: 40, backgroundColor: FontMessageRenderer.beige, maxAspectRatio: 1.5)
        messagePreviewView = MessageDisplayView(frame: view.bounds)
        messagePreviewView.delegate = self
        view.addSubview(messagePreviewView)
        messagePreviewView.image = image
    }

    private lazy var isAccessGranted: Bool = {
        let originalString = UIPasteboard.general.string
        UIPasteboard.general.string = "TEST"
        if UIPasteboard.general.hasStrings {
            UIPasteboard.general.string = originalString
            return true
        }
        return false
    }()
}

extension KeyboardViewController: KeyboardButtonDelegate {
    func didSingleTapButton(_ button: KeyboardButton) {
        let proxy = textDocumentProxy

        switch button.type {
        case .character(let c):
            proxy.insertText(c)
            if c == "." || c == "!" || c == "?" {
                setKeyboardType(.shifted)
            } else if keyboardType == .shifted {
                setKeyboardType(.lower)
            }
        case .backspace:
            proxy.deleteBackward()
        case .nextKeyboard:
            advanceToNextInputMode()
        case .returnOrDone(_):
            proxy.insertText("\n")
            setKeyboardType(.shifted)
        case .space:
            proxy.insertText(" ")
            setKeyboardType(.lower)
        case .switchToKeyboardTypes(let keyboardTypes, _):
            setKeyboardType(keyboardTypes.first!)
        }
    }

    func didDoubleTapButton(_ button: KeyboardButton) {
        switch button.type {
        case .switchToKeyboardTypes(let keyboardTypes, _):
            setKeyboardType(keyboardTypes.last!)
        case .space:
            textDocumentProxy.insertText(". ")
            setKeyboardType(.shifted)
        default:
            break
        }
    }
}

extension KeyboardViewController: MessageDisplayViewDelegate {
    func copyToClipboardButtonPressed() {
        UIPasteboard.general.image = messagePreviewView.image
        hoistSuccessLabel()
        removeMessageView()
    }

    func continueEditingButtonPressed() {
        textDocumentProxy.insertText(message)
        removeMessageView()
    }

    private func removeMessageView() {
        messagePreviewView.removeFromSuperview()
        messagePreviewView = nil
    }
}
