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
    typealias Event = (String) -> Void
    
    private var proxy:UITextDocumentProxy!
    private var timer:NSTimer?
    private var onCompleteEvent:Event!
    private var consumedLines:[String]!
    private var lastLine:String?
    
    func consume(proxy:UITextDocumentProxy, onCompleteEvent:Event) {
        self.proxy = proxy
        self.onCompleteEvent = onCompleteEvent
        consumedLines = []
        
        lastLine = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        proxy.adjustTextPositionByCharacterOffset((proxy.documentContextAfterInput ?? "").characters.count + 1)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "handleForwardTimer:", userInfo: nil, repeats: true)
    }
    
    func handleForwardTimer(timer:NSTimer) {
        let currentLine = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        if lastLine == currentLine {
            self.timer!.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "handleBackwardTimer:", userInfo: nil, repeats: true)
        }
        else {
            lastLine = currentLine
            proxy.adjustTextPositionByCharacterOffset((proxy.documentContextAfterInput ?? "").characters.count + 1)
        }
    }
    
    func handleBackwardTimer(timer:NSTimer) {
        if !proxy.hasText() {
            self.timer!.invalidate()
            //We need to wait a bit longer to confirm
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "handleConfirmTimer:", userInfo: nil, repeats: false)
        }
        else
        {
            let currentText = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
            consumedLines.insert(currentText, atIndex: 0)
            proxy.adjustTextPositionByCharacterOffset((proxy.documentContextAfterInput ?? "").characters.count)
            var charactersRemaining = currentText.characters.count
            while charactersRemaining > 0 {
                proxy.deleteBackward()
                --charactersRemaining
            }
        }
    }
    
    func handleConfirmTimer(timer:NSTimer) {
        self.timer!.invalidate()
        //We still have no new text? Great!
        if !proxy.hasText() {
            var message:String = ""
            if consumedLines.count > 0 {
                message = consumedLines.joinWithSeparator("")
            }
            onCompleteEvent(message)
        }
        else //Oh, more text, lets get this thing going again
        {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "handleBackwardTimer:", userInfo: nil, repeats: true)
        }
    }
}