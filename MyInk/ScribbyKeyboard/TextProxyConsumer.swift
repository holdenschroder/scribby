//
//  TextProxyConsumer.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-21.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

/** TextProxyConsumer attempts to get around a limitation of UITextDocumentProxy. The issue with the proxy is that it only gives you a limited view of the text in the targetted field and UIInputViewControllers cannot directly access the UI Element they are targetting. So we instead attempt to step the proxy's text position to the end of the text and then create a complete message by recording what we see, deleting, waiting and seeing if anything new appears.
 */
class TextProxyConsumer:NSObject {
    typealias Event = ((String) -> (Void))

    private var proxy: UITextDocumentProxy!
    private var timer: Timer?
    private var onCompleteEvent: Event!
    private var consumedLines: [String]!
    private var lastLine: String?

    func consume(proxy: UITextDocumentProxy, onCompleteEvent: @escaping Event) {
        self.proxy = proxy
        self.onCompleteEvent = onCompleteEvent
        consumedLines = []

        lastLine = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        let nextCharacterPosition = (proxy.documentContextAfterInput ?? "").characters.count + 1
        proxy.adjustTextPosition(byCharacterOffset: nextCharacterPosition)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(handleForwardTimer(_:)), userInfo: nil, repeats: true)
    }

    func handleForwardTimer(_ timer: Timer) {
        let currentLine = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        if lastLine == currentLine {
            self.timer!.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(handleBackwardTimer(_:)), userInfo: nil, repeats: true)
        }
        else {
            lastLine = currentLine
            let nextCharacterPosition = (proxy.documentContextAfterInput ?? "").characters.count + 1
            proxy.adjustTextPosition(byCharacterOffset: nextCharacterPosition)
        }
    }

    func handleBackwardTimer(_ timer: Timer) {
        if !proxy.hasText {
            self.timer!.invalidate()

            //We need to wait a bit longer to confirm
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleConfirmTimer(_:)), userInfo: nil, repeats: false)
        }
        else
        {
            let currentText = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
            consumedLines.insert(currentText, at: 0)
            let characterCount = (proxy.documentContextAfterInput ?? "").characters.count
            proxy.adjustTextPosition(byCharacterOffset: characterCount)
            var charactersRemaining = currentText.characters.count
            while charactersRemaining > 0 {
                proxy.deleteBackward()
                charactersRemaining -= 1
            }
        }
    }

    func handleConfirmTimer(_ timer: Timer) {
        self.timer!.invalidate()

        if !proxy.hasText {
        //We still have no new text? Great!
            var message: String = ""
            if consumedLines.count > 0 {
                message = consumedLines.joined()
            }
            onCompleteEvent(message)
        } else {
            //Oh, more text, lets get this thing going again
            self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(handleBackwardTimer(_:)), userInfo: nil, repeats: true)
        }
    }
}
