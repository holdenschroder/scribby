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
    var keyboardView: UIView!
    var rowViews: [UIView]!
    var atlas: FontAtlas?
    var fallbackAtlas: FontAtlas?
    lazy var coreData: CoreDataHelper = {
        return CoreDataHelper()
    }()
    fileprivate var _messageRenderer: FontMessageRenderer?
    fileprivate var _lastKeyPressDate: Date?
    fileprivate var _lastKeyValue: String?
    fileprivate var _baseViewConstraints = [NSLayoutConstraint]()
    fileprivate var _currentKeyboardLayout: KeyboardLayouts = .alpha
    fileprivate var _capitilization: CapitilizationState = .lowercase
    fileprivate var _lastKeyboardBounds: CGRect?
    fileprivate var _hasFirstLayout: Bool = false
    fileprivate var _loadedImages: [String:UIImage] = [:]
    fileprivate var _textProxyConsumer: TextProxyConsumer!
    fileprivate var _shiftButton: UIMyInkKey?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        keyboardView = UIView(frame: CGRect.zero)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let proxy = self.textDocumentProxy 
        if proxy.autocapitalizationType == UITextAutocapitalizationType.sentences {
            if proxy.hasText {
                _capitilization = .lowercase
            }
            else {
                _capitilization = .uppercase
            }
            
            updateShiftButtonVisualization()
        }
        
        KeyboardAnalytics.TrackEvent(SharedMyInkValues.kEventKeyboardAppeared)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        KeyboardAnalytics.TrackEvent(SharedMyInkValues.kEventKeyboardDisappeared)
    }
    
    override func viewDidLayoutSubviews() {
        if inputView?.bounds == CGRect.zero {
            return
        }
        
        let bounds = inputView!.bounds
        keyboardView.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
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
    
    func buildKeyboard(_ layout: KeyboardLayouts) {
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let bounds = inputView!.bounds
        
        if _currentKeyboardLayout != layout {
            KeyboardAnalytics.TrackEvent(SharedMyInkValues.kEventKeyboardSwitched, parameters: ["Type": String(describing: layout)])
        }
        
        _currentKeyboardLayout = layout
        
        keyboardView.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = nil
        
        var buttonTitles1, buttonTitles2, buttonTitles3, buttonTitles4:[AnyObject]!
        
        let deleteKey = UIMyInkKey(title: "⌫", relativeWidth: 0.15)
        deleteKey.addTarget(self, action: #selector(KeyboardViewController.handleDeleteKeyPressed(_:)), for: .touchDown)
        deleteKey.addTarget(self, action: #selector(KeyboardViewController.handleDeleteKeyReleased(_:)), for: .touchUpInside)
        
        switch layout {
        case .alpha:
            let shiftKey = UIMyInkKey(icon: loadImage("KeyboardIcon_Shift"), relativeWidth: 0.15)
            if _capitilization == .uppercase {
                shiftKey.keyData?.controlState = UIControlState.selected
            }
            shiftKey.addTarget(self, action: #selector(KeyboardViewController.handleShiftTap(_:event:)), for: .touchUpInside)
            self._shiftButton = shiftKey
            
            buttonTitles1 = ["Q" as AnyObject, "W" as AnyObject, "E" as AnyObject, "R" as AnyObject, "T" as AnyObject, "Y" as AnyObject, "U" as AnyObject, "I" as AnyObject, "O" as AnyObject, "P" as AnyObject]
            buttonTitles2 = ["A" as AnyObject, "S" as AnyObject, "D" as AnyObject, "F" as AnyObject, "G" as AnyObject, "H" as AnyObject, "J" as AnyObject, "K" as AnyObject, "L" as AnyObject]
            buttonTitles3 = [shiftKey, "Z" as AnyObject, "X" as AnyObject, "C" as AnyObject, "V" as AnyObject, "B" as AnyObject, "N" as AnyObject, "M" as AnyObject, deleteKey]
            buttonTitles4 = ["123" as AnyObject]
        case .numeric:
            buttonTitles1 = ["1" as AnyObject, "2" as AnyObject, "3" as AnyObject, "4" as AnyObject, "5" as AnyObject, "6" as AnyObject, "7" as AnyObject, "8" as AnyObject, "9" as AnyObject, "0" as AnyObject]
            buttonTitles2 = ["-" as AnyObject, "/" as AnyObject, ":" as AnyObject, ";" as AnyObject, "(" as AnyObject, ")" as AnyObject, "$" as AnyObject, "&" as AnyObject, "@" as AnyObject, "\"" as AnyObject]
            buttonTitles3 = ["." as AnyObject, "," as AnyObject, "?" as AnyObject, "!" as AnyObject, "'" as AnyObject, deleteKey]
            buttonTitles4 = ["abc" as AnyObject]
        default:
            buttonTitles1 = ["" as AnyObject]
            buttonTitles2 = ["" as AnyObject]
            buttonTitles3 = ["" as AnyObject]
            buttonTitles4 = ["" as AnyObject]
        }
        
        let inkKey = UIMyInkKey(title: "Ink", relativeWidth: nil)
        inkKey.keyData?.normalColorState = KeyColorState(textColor: UIColor.white, backgroundColor: SharedMyInkValues.MyInkPinkColor)
        buttonTitles4.append(["🌐", UIMyInkKey(title: "space", relativeWidth: 0.4), UIMyInkKey(title: "⏎", relativeWidth: 0.15), inkKey] as AnyObject)
        
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
    
    func setupButton(_ button: UIMyInkKey) {
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.sizeToFit()
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGray, for: UIControlState())
        button.layer.cornerRadius = 5
    }
    
    func createRow(_ width: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func populateRowWithButtons(_ rowView: UIView, buttonData: [AnyObject]) {
        var buttons: [UIButton] = []
        
        var firstUnreservedSizeItem:UIButton?
        for data in buttonData {
            var button: UIMyInkKey?
            var widthConstraint: NSLayoutConstraint?
            
            if let dataString = data as? String {
                button = UIMyInkKey(title: dataString, relativeWidth: nil)
                setupButton(button!)
                button!.addTarget(self, action: #selector(KeyboardViewController.didTapButton(_:)), for: .touchUpInside)
                button!.setTitle(dataString, for: UIControlState())
            }
            else if let buttonData = data as? UIMyInkKey {
                button = buttonData
                setupButton(button!)
                //We should add the default target if nothing is already added to this button
                if button?.allTargets.count == 0 && button?.gestureRecognizers == nil {
                    button?.addTarget(self, action: #selector(KeyboardViewController.didTapButton(_:)), for: .touchUpInside)
                }
                if button!.keyData?.relativeWidth != nil {
                    widthConstraint = NSLayoutConstraint(item: button!, attribute: .width, relatedBy: .equal, toItem: rowView, attribute: .width, multiplier: button!.keyData!.relativeWidth!, constant: 0)
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
                        widthConstraint = NSLayoutConstraint(item: button!, attribute: .width, relatedBy: .equal, toItem: firstUnreservedSizeItem!, attribute: .width, multiplier: 1.0, constant: 0)
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
    
    func addIndividualButtonConstraints(_ buttons:[UIButton], mainView: UIView){
        
        for (index, button) in buttons.enumerated() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 4)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: -4)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1.0, constant: -4)
                
            }else{
                
                let nextButton = buttons[index+1]
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -4)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1.0, constant: 4)
                
            }else{
                
                let prevButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: .right, multiplier: 1.0, constant: 4)
            }
            
            //var widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: mainView, attribute: .Width, multiplier: buttonData.relativeWidth, constant: 0)
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsToBaseView(_ baseView: UIView, rowViews: [UIView]){
        
        baseView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepingCapacity: true)
        
        for (index, rowView) in rowViews.enumerated() {
            let centerXConstraint = NSLayoutConstraint(item: rowView, attribute: .centerX, relatedBy: .equal, toItem: baseView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: rowView, attribute: .width, relatedBy: .equal, toItem: baseView, attribute: .width, multiplier: 1.0, constant: 0)
            _baseViewConstraints.append(centerXConstraint)
            _baseViewConstraints.append(widthConstraint)
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: baseView, attribute: .top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0)
                
                _baseViewConstraints.append(heightConstraint)
            }
            _baseViewConstraints.append(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: baseView, attribute: .bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: nextRow, attribute: .top, multiplier: 1.0, constant: 0)
            }
            
            _baseViewConstraints.append(bottomConstraint)
        }
        
        baseView.addConstraints(_baseViewConstraints)
    }
    
    //MARK: View Functions
    
    func showAlert(_ message:String) {
        let bounds = inputView!.bounds
        
        _currentKeyboardLayout = .alert
        
        keyboardView.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = SharedMyInkValues.MyInkPinkColor
        
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.textColor = UIColor.white
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Okay", for: UIControlState())
        button.addTarget(self, action: #selector(KeyboardViewController.didTapAlertButton(_:)), for: UIControlEvents.touchUpInside)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        rowViews = [label, button]
        
        keyboardView.addSubview(label)
        keyboardView.addSubview(button)
        
        keyboardView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepingCapacity: true)
        
        let topLabelConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: keyboardView, attribute: .top, multiplier: 1.0, constant: 1)
        let bottomLabelConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: keyboardView, attribute: .bottom, multiplier: 1.0, constant: -50)
        let leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: keyboardView, attribute: .left, multiplier: 1.0, constant: 1)
        let rightLabelConstraint = NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: keyboardView, attribute: .right, multiplier: 1.0, constant: 1)
        
        //let topButtonConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: keyboardView, attribute: .Bottom, multiplier: 1.0, constant: -49)
        let bottomButtonConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: keyboardView, attribute: .bottom, multiplier: 1, constant: -10)
        let centerXButtonConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: keyboardView, attribute: .centerX, multiplier: 1.0, constant: 0)
        let widthButtonConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: keyboardView, attribute: .width, multiplier: 1, constant: -20)
        _baseViewConstraints = [topLabelConstraint, bottomLabelConstraint, leftLabelConstraint, rightLabelConstraint, bottomButtonConstraint, centerXButtonConstraint, widthButtonConstraint]
        keyboardView.addConstraints(_baseViewConstraints)
        keyboardView.layoutIfNeeded()
    }
    
    //ToDo - Show Message and Show Alert should be the same function
    func showMessage(_ message:String) {
        let bounds = inputView!.bounds
        
        _currentKeyboardLayout = .message
        
        keyboardView.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        keyboardView.invalidateIntrinsicContentSize()
        keyboardView.backgroundColor = SharedMyInkValues.MyInkPinkColor
        
        for row in rowViews {
            row.removeFromSuperview()
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.textColor = UIColor.white
        rowViews = [label]
        
        keyboardView.addSubview(label)
        
        keyboardView.removeConstraints(_baseViewConstraints)
        _baseViewConstraints.removeAll(keepingCapacity: true)
        
        let topLabelConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: keyboardView, attribute: .top, multiplier: 1.0, constant: 1)
        let bottomLabelConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: keyboardView, attribute: .bottom, multiplier: 1.0, constant: 1)
        let leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: keyboardView, attribute: .left, multiplier: 1.0, constant: 1)
        let rightLabelConstraint = NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: keyboardView, attribute: .right, multiplier: 1.0, constant: 1)
        
        _baseViewConstraints = [topLabelConstraint, bottomLabelConstraint, leftLabelConstraint, rightLabelConstraint]
        keyboardView.addConstraints(_baseViewConstraints)
        keyboardView.layoutIfNeeded()
    }
    
    func hideMessage() {
        buildKeyboard(.alpha)
    }
    
    //MARK: Button Handlers
    
    //todo: Buttons that are not inserting text should probably be changed to be handled with their own functions
    func didTapButton(_ sender: AnyObject?) {
        
        let button = sender as! UIButton
        let title = button.title(for: UIControlState())!
        let proxy = textDocumentProxy 
        
        let dateNow = Date()
        
        let autoCapitilization = proxy.autocapitalizationType
        
        let shouldUppercase = _capitilization != .lowercase && autoCapitilization == UITextAutocapitalizationType.sentences
        if _capitilization == .uppercase && autoCapitilization == UITextAutocapitalizationType.sentences {
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
                    let elapsedTime = dateNow.timeIntervalSince(_lastKeyPressDate!)
                    if elapsedTime < 1.0 {
                        proxy.deleteBackward()
                        proxy.insertText(".")
                        if autoCapitilization == UITextAutocapitalizationType.sentences {
                            _capitilization = .uppercase
                        }
                    }
                }
                if _lastKeyValue == "." {
                    if autoCapitilization == UITextAutocapitalizationType.sentences {
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
            proxy.insertText(shouldUppercase ? title.uppercased() : title.lowercased())
        }
        
        //keyboardView.playInputClick()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        
        updateShiftButtonVisualization()
        
        _lastKeyPressDate = dateNow
        _lastKeyValue = title
    }
    
    func handleShiftTap(_ sender: AnyObject, event: UIEvent) {
        let dateNow = Date()
        
        let touch = event.allTouches?.first
        
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
    
    func updateButtonVisualization(_ button:UIControl) {
        if let key = button as? UIMyInkKey {
            if key.keyData != nil {
                switch key.keyData!.controlState.rawValue {
                case UIControlState.selected.rawValue:
                    key.backgroundColor = key.keyData!.selectedColorState.backgroundColor
                    key.tintColor = key.keyData!.selectedColorState.tintColor
                default:
                    key.backgroundColor = key.keyData!.normalColorState.backgroundColor
                    key.tintColor = key.keyData!.normalColorState.tintColor
                }
                
                key.setTitleColor(key.keyData!.normalColorState.textColor, for: UIControlState())
                key.setTitleColor(key.keyData!.selectedColorState.textColor, for: UIControlState.selected)
            }
        }
    }
    
    func updateShiftButtonVisualization() {
        if _shiftButton != nil {
            DispatchQueue.main.async(execute: {
                
                    var buttonControlState = UIControlState()
                    
                    switch self._capitilization {
                    case .lowercase:
                        buttonControlState = UIControlState()
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_Shift"), for: UIControlState())
                    case .uppercase:
                        buttonControlState = UIControlState.selected
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_Shift"), for: UIControlState())
                    case .capslock:
                        buttonControlState = UIControlState()
                        self._shiftButton?.setImage(self.loadImage("KeyboardIcon_CapsLock"), for: UIControlState())
                    }
                    self._shiftButton?.keyData?.controlState = buttonControlState
                    self.updateButtonVisualization(self._shiftButton!)
            })
        }
    }
    
    fileprivate var deleteTimer:Timer?
    
    func handleDeleteKeyPressed(_ sender:AnyObject?) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        _lastKeyPressDate = Date()
        _lastKeyValue = "⌫"
        
        self.deleteTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(KeyboardViewController.handleDeleteKeyHeld(_:)), userInfo: nil, repeats: false)
    }
    
    func handleDeleteKeyReleased(_ sender:AnyObject?) {
        if self.deleteTimer != nil {
            self.deleteTimer?.invalidate()
            self.deleteTimer = nil
        }
    }
    
    func handleDeleteKeyHeld(_ timer:Timer) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        self.deleteTimer?.invalidate()
        self.deleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.handleDeleteKeyHeldLong(_:)), userInfo: nil, repeats: true)
    }
    
    func handleDeleteKeyHeldLong(_ timer:Timer) {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
        if isFullAccessGranted() {
            AudioServicesPlaySystemSound(0x450);
        }
        if proxy.hasText == false {
            timer.invalidate()
            self.deleteTimer = nil
        }
    }
    
    func didTapAlertButton(_ sender: AnyObject?) {
        buildKeyboard(.alpha)
    }
    
    func renderMessage(_ button:UIButton) {
        if isFullAccessGranted() == false {
            showAlert("You need to enable the 'Allow Full Access' option under Settings/General/Keyboard/Keyboards/MyInkKeyboard - MyInk.")
            return
        }
        
        let proxy = textDocumentProxy
        showMessage("Processing")
        _textProxyConsumer.consume(proxy, onCompleteEvent: handleProxyConsumerComplete)
    }
    
    func handleProxyConsumerComplete(_ message:String) -> Void {
        hideMessage()
        if(message.characters.count > 0) {
            //Height is expected to be cropped shorter, possibly the width also if the messages are short. If the message is much longer then it cannot
            //be viewed as a preview in the Messages app
            if let messageImage = _messageRenderer!.render(message: message, width: 750, lineHeight: 36, backgroundColor: FontMessageRenderer.beige, maxAspectRatio: 1.75) {
                UIPasteboard.general.image = messageImage
                
                //Create message
                let floatingTextPosition = CGPoint(x: keyboardView.bounds.width * 0.5, y: 0)//button.frame.origin - CGPoint(x: 100, y: 20)
                let floatingText = UILabel(frame: CGRect(origin: floatingTextPosition, size: CGSize(width: 100, height: 20)))
                floatingText.backgroundColor = UIColor(white: 0, alpha: 0.8)
                floatingText.textColor = UIColor(white: 1, alpha: 1)
                floatingText.textAlignment = NSTextAlignment.center
                floatingText.text = "copied to clipboard"
                floatingText.sizeToFit()
                floatingText.frame.size = floatingText.frame.size + CGSize(width: 5, height: 5)
                floatingText.frame.origin.x = floatingText.frame.origin.x - (floatingText.frame.size.width * 0.5)
                keyboardView.addSubview(floatingText)
                UIView.animate(withDuration: 3.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    floatingText.alpha = 0.0
                    }, completion: { (completed:Bool) in
                        floatingText.removeFromSuperview()
                })
                
                let numCharacters:Int = message.characters.count
                KeyboardAnalytics.TrackEvent(SharedMyInkValues.kEventRenderMessage, parameters: ["NumCharacters":String(numCharacters)])
            }
        }
    }
    
    //MARK: Helper Functions
    
    func isFullAccessGranted() -> Bool {
        let pasteboard:UIPasteboard? = UIPasteboard.general
        return pasteboard != nil
    }
    
    func loadImage(_ named:String) -> UIImage {
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
