//
//  KeyboardViewController.swift
//  MyInkKeyboard
//
//  Created by Galen Ryder on 2015-08-04.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class KeyboardViewController: UIInputViewController {
    enum KeyboardLayouts {
        case alpha, numeric, alert, message
    }
    
    enum CapitilizationState {
        case lowercase, uppercase, capslock
    }
    
    @IBOutlet var nextKeyboardButton: UIButton!
    var keyboardView:UIView!
    var rowViews:[UIView]!
    var atlas:FontAtlas?
    var fallbackAtlas:FontAtlas?
    lazy var coreData:CoreDataHelper = {
        return CoreDataHelper()
    }()
    private var _messageRenderer:FontMessageRenderer?
    private var _lastKeyPressDate:NSDate?
    private var _lastKeyValue:String?
    private var _baseViewConstraints = [NSLayoutConstraint]()
    private var _currentKeyboardLayout:KeyboardLayouts = .alpha
    private var _capitilization:CapitilizationState = .lowercase
    private var _lastKeyboardBounds:CGRect?
    private var _hasFirstLayout:Bool = false
    private var _loadedImages:[String:UIImage] = [:]
    private var _textProxyConsumer:TextProxyConsumer!
    private var _shiftButton:UIMyInkKey?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        keyboardView = UIView(frame: CGRectZero)
        //keyboardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        inputView?.addSubview(keyboardView)
        rowViews = [UIView]()
        
        if isFullAccessGranted() {
            atlas = FontAtlas(name: SharedMyInkValues.DefaultUserAtlas, atlasDirectory: SharedMyInkValues.DefaultAtlasDirectory, managedObjectContext: self.coreData.managedObjectContext!)
            fallbackAtlas = FontAtlas(name: SharedMyInkValues.EmbeddedAtlasName, atlasDirectory: SharedMyInkValues.EmbeddedAtlasDirectory, managedObjectContext: self.coreData.embeddedManagedObjectContext!)
            _messageRenderer = FontMessageRenderer(atlas: atlas!, fallbackAtlas:fallbackAtlas!, watermark:SharedMyInkValues.MyInkWatermark)
        }
        
        _textProxyConsumer = TextProxyConsumer()
        
        KeyboardAnalytics.Initialize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let proxy = self.textDocumentProxy 
        if proxy.autocapitalizationType == UITextAutocapitalizationType.Sentences {
            if proxy.hasText() {
                _capitilization = .lowercase
            }
            else {
                _capitilization = .uppercase
            }
            
            updateShiftButtonVisualization()
        }
        
        KeyboardAnalytics.TrackEvent("Keyboard_Appeared")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        KeyboardAnalytics.TrackEvent("Keyboard_Disappeared")
    }
    
    override func viewDidLayoutSubviews() {
        if inputView?.bounds == CGRectZero {
            return
        }
        
        let bounds = inputView!.bounds
        keyboardView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        
        if !_hasFirstLayout {
            buildKeyboard(_currentKeyboardLayout)
            _hasFirstLayout = true
        }
        
        keyboardView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    //MARK: Setup
    
    func buildKeyboard(layout:KeyboardLayouts) {
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let bounds = inputView!.bounds
        
        if _currentKeyboardLayout != layout {
            KeyboardAnalytics.TrackEvent("SwitchedKeyboard", parameters: ["Type":String(layout)])
        }
        
        _currentKeyboardLayout = layout
        
        keyboardView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = nil
        
        var buttonTitles1, buttonTitles2, buttonTitles3, buttonTitles4:[AnyObject]!
        
        let deleteKey = UIMyInkKey(title: "⌫", relativeWidth: 0.15)
        deleteKey.addTarget(self, action: "handleDeleteKeyPressed:", forControlEvents: .TouchDown)
        deleteKey.addTarget(self, action: "handleDeleteKeyReleased:", forControlEvents: .TouchUpInside)
        
        switch layout {
        case .alpha:
            let shiftKey = UIMyInkKey(icon: loadImage("KeyboardIcon_Shift"), relativeWidth: 0.15)
            if _capitilization == .uppercase {
                shiftKey.keyData?.controlState = UIControlState.Selected
            }
            shiftKey.addTarget(self, action: "handleShiftTap:event:", forControlEvents: .TouchUpInside)
            self._shiftButton = shiftKey
            
            buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
            buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
            buttonTitles3 = [shiftKey, "Z", "X", "C", "V", "B", "N", "M", deleteKey]
            buttonTitles4 = ["123"]
        case .numeric:
            buttonTitles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
            buttonTitles2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
            buttonTitles3 = [".", ",", "?", "!", "'", deleteKey]
            buttonTitles4 = ["abc"]
        default:
            buttonTitles1 = [""]
            buttonTitles2 = [""]
            buttonTitles3 = [""]
            buttonTitles4 = [""]
        }
        
        let inkKey = UIMyInkKey(title: "Ink", relativeWidth: nil)
        inkKey.keyData?.normalColorState = KeyColorState(textColor: UIColor.whiteColor(), backgroundColor: SharedMyInkValues.MyInkPinkColor)
        buttonTitles4.appendContentsOf(["🌐", UIMyInkKey(title: "space", relativeWidth: 0.4), UIMyInkKey(title: "⏎", relativeWidth: 0.15), inkKey])
        
        let row1 = createRow(bounds.width)
        let row2 = createRow(bounds.width)
        let row3 = createRow(bounds.width)
        let row4 = createRow(bounds.width)

        keyboardView.addSubview(row1)
        keyboardView.addSubview(row2)
        keyboardView.addSubview(row3)
        keyboardView.addSubview(row4)
        
        rowViews = [row1, row2, row3, row4]
        
        addConstraintsToBaseView(keyboardView, rowViews: rowViews)
    
        populateRowWithButtons(row1, buttonData: buttonTitles1)
        populateRowWithButtons(row2, buttonData: buttonTitles2)
        populateRowWithButtons(row3, buttonData: buttonTitles3)
        populateRowWithButtons(row4, buttonData: buttonTitles4)
        
        updateShiftButtonVisualization()
        
        _lastKeyboardBounds = bounds
    }
    
    func setupButton(button:UIMyInkKey) {
        button.frame = CGRectMake(0, 0, 20, 20)
        button.sizeToFit()
        button.titleLabel!.font = UIFont.systemFontOfSize(20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.layer.cornerRadius = 5
    }
    
    func createRow(width:CGFloat) -> UIView {
        let view = UIView(frame: CGRectMake(0, 0, width, 50))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func populateRowWithButtons(rowView: UIView, buttonData: [AnyObject]) {
        var buttons:[UIButton] = []
        
        var firstUnreservedSizeItem:UIButton?
        for data in buttonData {
            var button:UIMyInkKey?
            var widthConstraint:NSLayoutConstraint?
            
            if let dataString = data as? String {
                button = UIMyInkKey(title: dataString, relativeWidth: nil)
                setupButton(button!)
                button!.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
                button!.setTitle(dataString, forState: .Normal)
            }
            else if let buttonData = data as? UIMyInkKey {
                button = buttonData
                setupButton(button!)
                //We should add the default target if nothing is already added to this button
                if button?.allTargets().count == 0 && button?.gestureRecognizers == nil {
                    button?.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
                }
                if button!.keyData?.relativeWidth != nil {
                    widthConstraint = NSLayoutConstraint(item: button!, attribute: .Width, relatedBy: .Equal, toItem: rowView, attribute: .Width, multiplier: button!.keyData!.relativeWidth!, constant: 0)
                }
                
                if button != nil {
                    updateButtonVisualization(button!)
                }
            }
            
            if button != nil {
                if widthConstraint == nil {
                    if firstUnreservedSizeItem == nil {
                        firstUnreservedSizeItem = button
                    }
                    else {
                        widthConstraint = NSLayoutConstraint(item: button!, attribute: .Width, relatedBy: .Equal, toItem: firstUnreservedSizeItem!, attribute: .Width, multiplier: 1.0, constant: 0)
                    }
                }
                
                buttons.append(button!)
                rowView.addSubview(button!)
                if widthConstraint != nil {
                    rowView.addConstraint(widthConstraint!)
                }
            }
        }
        
        addIndividualButtonConstraints(buttons, mainView: rowView)
    }
    
    func addIndividualButtonConstraints(buttons:[UIButton], mainView: UIView){
        
        for (index, button) in buttons.enumerate() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 4)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -4)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -4)
                
            }else{
                
                let nextButton = buttons[index+1]
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -4)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 4)
                
            }else{
                
                let prevButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevButton, attribute: .Right, multiplier: 1.0, constant: 4)
            }
            
            //var widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: mainView, attribute: .Width, multiplier: buttonData.relativeWidth, constant: 0)
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsToBaseView(baseView: UIView, rowViews: [UIView]){
        
        baseView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepCapacity: true)
        
        for (index, rowView) in rowViews.enumerate() {
            let centerXConstraint = NSLayoutConstraint(item: rowView, attribute: .CenterX, relatedBy: .Equal, toItem: baseView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: rowView, attribute: .Width, relatedBy: .Equal, toItem: baseView, attribute: .Width, multiplier: 1.0, constant: 0)
            _baseViewConstraints.append(centerXConstraint)
            _baseViewConstraints.append(widthConstraint)
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: baseView, attribute: .Top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .Height, relatedBy: .Equal, toItem: rowView, attribute: .Height, multiplier: 1.0, constant: 0)
                
                _baseViewConstraints.append(heightConstraint)
            }
            _baseViewConstraints.append(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: baseView, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            _baseViewConstraints.append(bottomConstraint)
        }
        
        baseView.addConstraints(_baseViewConstraints)
    }
    
    //MARK: View Functions
    
    func showAlert(message:String) {
        let bounds = inputView!.bounds
        
        _currentKeyboardLayout = .alert
        
        keyboardView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = SharedMyInkValues.MyInkPinkColor
        
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = message
        label.textColor = UIColor.whiteColor()
        let button = UIButton(type: .System)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Okay", forState: UIControlState.Normal)
        button.addTarget(self, action: "didTapAlertButton:", forControlEvents: UIControlEvents.TouchUpInside)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        rowViews = [label, button]
        
        keyboardView.addSubview(label)
        keyboardView.addSubview(button)
        
        keyboardView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepCapacity: true)
        
        let topLabelConstraint = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: keyboardView, attribute: .Top, multiplier: 1.0, constant: 1)
        let bottomLabelConstraint = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: keyboardView, attribute: .Bottom, multiplier: 1.0, constant: -50)
        let leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: keyboardView, attribute: .Left, multiplier: 1.0, constant: 1)
        let rightLabelConstraint = NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: keyboardView, attribute: .Right, multiplier: 1.0, constant: 1)
        
        //let topButtonConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: keyboardView, attribute: .Bottom, multiplier: 1.0, constant: -49)
        let bottomButtonConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: keyboardView, attribute: .Bottom, multiplier: 1, constant: -10)
        let centerXButtonConstraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: keyboardView, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let widthButtonConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: keyboardView, attribute: .Width, multiplier: 1, constant: -20)
        _baseViewConstraints = [topLabelConstraint, bottomLabelConstraint, leftLabelConstraint, rightLabelConstraint, bottomButtonConstraint, centerXButtonConstraint, widthButtonConstraint]
        keyboardView.addConstraints(_baseViewConstraints)
        keyboardView.layoutIfNeeded()
    }
    
    //ToDo - Show Message and Show Alert should be the same function
    func showMessage(message:String) {
        let bounds = inputView!.bounds
        
        _currentKeyboardLayout = .message
        
        keyboardView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = SharedMyInkValues.MyInkPinkColor
        
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = message
        label.textColor = UIColor.whiteColor()
        rowViews = [label]
        
        keyboardView.addSubview(label)
        
        keyboardView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepCapacity: true)
        
        let topLabelConstraint = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: keyboardView, attribute: .Top, multiplier: 1.0, constant: 1)
        let bottomLabelConstraint = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: keyboardView, attribute: .Bottom, multiplier: 1.0, constant: 1)
        let leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: keyboardView, attribute: .Left, multiplier: 1.0, constant: 1)
        let rightLabelConstraint = NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: keyboardView, attribute: .Right, multiplier: 1.0, constant: 1)
        
        _baseViewConstraints = [topLabelConstraint, bottomLabelConstraint, leftLabelConstraint, rightLabelConstraint]
        keyboardView.addConstraints(_baseViewConstraints)
        keyboardView.layoutIfNeeded()
    }
    
    func hideMessage() {
        buildKeyboard(.alpha)
    }
    
    //MARK: Button Handlers
    
    //todo: Buttons that are not inserting text should probably be changed to be handled with their own functions
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as! UIButton
        let title = button.titleForState(.Normal)!
        let proxy = textDocumentProxy 
        
        let dateNow = NSDate()
        
        let autoCapitilization = proxy.autocapitalizationType
        
        let shouldUppercase = _capitilization != .lowercase && autoCapitilization == UITextAutocapitalizationType.Sentences
        if _capitilization == .uppercase && autoCapitilization == UITextAutocapitalizationType.Sentences {
            _capitilization = .lowercase
        }
        
        switch title {
        case "⌫" :
            proxy.deleteBackward()
        case "⏎" :
            proxy.insertText("\n")
            _capitilization = .uppercase
        case "space" :
            if _lastKeyPressDate != nil {
                if _lastKeyValue == "space" {
                    let elapsedTime = dateNow.timeIntervalSinceDate(_lastKeyPressDate!)
                    if elapsedTime < 1.0 {
                        proxy.deleteBackward()
                        proxy.insertText(".")
                        if autoCapitilization == UITextAutocapitalizationType.Sentences {
                            _capitilization = .uppercase
                        }
                    }
                }
                if _lastKeyValue == "." {
                    if autoCapitilization == UITextAutocapitalizationType.Sentences {
                        _capitilization = .uppercase
                        buildKeyboard(.alpha)
                    }
                }
            }
            proxy.insertText(" ")
        case "🌐" :
            self.advanceToNextInputMode()
        case "Ink":
            renderMessage(button)
        case "123":
            buildKeyboard(.numeric)
        case "abc":
            buildKeyboard(.alpha)
        default :
            proxy.insertText(shouldUppercase ? title.uppercaseString : title.lowercaseString)
        }
        
        //keyboardView.playInputClick()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        
        updateShiftButtonVisualization()
        
        _lastKeyPressDate = dateNow
        _lastKeyValue = title
    }
    
    func handleShiftTap(sender: AnyObject, event: UIEvent) {
        let dateNow = NSDate()
        
        let touch = event.allTouches()?.first
        
        if(touch?.tapCount == 1) {
            switch _capitilization {
            case .lowercase:
                _capitilization = .uppercase
            case .uppercase:
                _capitilization = .lowercase
            case .capslock:
                _capitilization = .lowercase
            }
        }
        else if(touch?.tapCount == 2) {
            if _capitilization != .capslock {
                _capitilization = .capslock
            }
        }
        
        updateShiftButtonVisualization()
        
        _lastKeyPressDate = dateNow
        _lastKeyValue = "shift"
    }
    
    func updateButtonVisualization(button:UIControl) {
        if let key = button as? UIMyInkKey {
            if key.keyData != nil {
                switch key.keyData!.controlState.rawValue {
                case UIControlState.Selected.rawValue:
                    key.backgroundColor = key.keyData!.selectedColorState.backgroundColor
                    key.tintColor = key.keyData!.selectedColorState.tintColor
                default:
                    key.backgroundColor = key.keyData!.normalColorState.backgroundColor
                    key.tintColor = key.keyData!.normalColorState.tintColor
                }
                
                key.setTitleColor(key.keyData!.normalColorState.textColor, forState: UIControlState.Normal)
                key.setTitleColor(key.keyData!.selectedColorState.textColor, forState: UIControlState.Selected)
            }
        }
    }
    
    func updateShiftButtonVisualization() {
        if _shiftButton != nil {
            dispatch_async(dispatch_get_main_queue(), {
                
                    var buttonControlState = UIControlState.Normal
                    
                    switch self._capitilization {
                    case .lowercase:
                        buttonControlState = UIControlState.Normal
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_Shift"), forState: .Normal)
                    case .uppercase:
                        buttonControlState = UIControlState.Selected
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_Shift"), forState: .Normal)
                    case .capslock:
                        buttonControlState = UIControlState.Normal
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_CapsLock"), forState: .Normal)
                    }
                    self._shiftButton?.keyData?.controlState = buttonControlState
                    self.updateButtonVisualization(self._shiftButton!)
            })
        }
    }
    
    private var deleteTimer:NSTimer?
    
    func handleDeleteKeyPressed(sender:AnyObject?) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        _lastKeyPressDate = NSDate()
        _lastKeyValue = "⌫"
        
        self.deleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "handleDeleteKeyHeld:", userInfo: nil, repeats: false)
    }
    
    func handleDeleteKeyReleased(sender:AnyObject?) {
        if self.deleteTimer != nil {
            self.deleteTimer?.invalidate()
            self.deleteTimer = nil
        }
    }
    
    func handleDeleteKeyHeld(timer:NSTimer) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        self.deleteTimer?.invalidate()
        self.deleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "handleDeleteKeyHeldLong:", userInfo: nil, repeats: true)
    }
    
    func handleDeleteKeyHeldLong(timer:NSTimer) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        if proxy.hasText() == false {
            timer.invalidate()
            self.deleteTimer = nil
        }
    }
    
    func didTapAlertButton(sender: AnyObject?) {
        buildKeyboard(.alpha)
    }
    
    func renderMessage(button:UIButton) {
        if isFullAccessGranted() == false {
            showAlert("You need to enable the 'Allow Full Access' option under Settings/General/Keyboard/Keyboards/MyInkKeyboard - MyInk.")
            return
        }
        
        let proxy = textDocumentProxy
        showMessage("Processing")
        _textProxyConsumer.consume(proxy, onCompleteEvent: handleProxyConsumerComplete)
    }
    
    func handleProxyConsumerComplete(message:String) -> Void {
        hideMessage()
        if(message.characters.count > 0) {
            //Height is expected to be cropped shorter, possibly the width also if the messages are short. If the message is much longer then it cannot
            //be viewed as a preview in the Messages app
            let messageImage = _messageRenderer!.renderMessage(message, imageSize: CGSize(width: 280, height: 4096), lineHeight:18, backgroundColor: UIColor.whiteColor(), showDebugInfo: false)
            
            if messageImage != nil {
                UIPasteboard.generalPasteboard().image = messageImage
                
                //Create message
                let floatingTextPosition = CGPoint(x: keyboardView.bounds.width * 0.5, y: 0)//button.frame.origin - CGPoint(x: 100, y: 20)
                let floatingText = UILabel(frame: CGRect(origin: floatingTextPosition, size: CGSize(width: 100, height: 20)))
                floatingText.backgroundColor = UIColor(white: 0, alpha: 0.8)
                floatingText.textColor = UIColor(white: 1, alpha: 1)
                floatingText.textAlignment = NSTextAlignment.Center
                floatingText.text = "copied to clipboard"
                floatingText.sizeToFit()
                floatingText.frame.size = floatingText.frame.size + CGSize(width: 5, height: 5)
                floatingText.frame.origin.x = floatingText.frame.origin.x - (floatingText.frame.size.width * 0.5)
                keyboardView.addSubview(floatingText)
                UIView.animateWithDuration(3.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    floatingText.alpha = 0.0
                    }, completion: { (completed:Bool) in
                        floatingText.removeFromSuperview()
                })
                
                let numCharacters:Int = message.characters.count
                KeyboardAnalytics.TrackEvent("RenderMessage", parameters: ["NumCharacters":String(numCharacters)])
            }
        }
    }
    
    //MARK: Helper Functions
    
    func isFullAccessGranted() -> Bool {
        let pasteboard:UIPasteboard? = UIPasteboard.generalPasteboard()
        return pasteboard != nil
    }
    
    func loadImage(named:String) -> UIImage {
        var image = _loadedImages[named]
        if image == nil {
            image = UIImage(named: named)
            if image != nil {
                _loadedImages.updateValue(image!, forKey: named)
            }
        }
        
        return image!
    }
}
