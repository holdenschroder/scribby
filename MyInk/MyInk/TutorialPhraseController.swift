//
//  TutorialPhraseController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-23.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TutorialPhraseController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    private let phrase:String! = "QUICK BROWN FOX JUMPS OVER THE LAZY DOG"
    private var words:[String]!
    private var unwrittenCharacters = Set<Character>()
    private var _messageRenderer:FontMessageRenderer?
    private var _tutorialState:TutorialState?
    private var _updateSizesTimer:NSTimer?
    private var _sections:NSIndexSet!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var finishButton: UIBarButtonItem!
    @IBOutlet weak var messageImageView:UIImageView!
    
    //MARK: Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
        words = phrase.componentsSeparatedByString(" ")
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _messageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: nil)
        }
        
        if _tutorialState == nil {
            _tutorialState = (UIApplication.sharedApplication().delegate as! AppDelegate).tutorialState
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false

        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 1000.0
        self.automaticallyAdjustsScrollViewInsets = false
        
        let currentAtlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        if currentAtlas != nil {
            for word in words {
                for character in word.characters {
                    if !currentAtlas!.hasGlyphMapping(String(character)) {
                        unwrittenCharacters.insert(character)
                    }
                }
            }
        }
        finishButton?.enabled = unwrittenCharacters.count == 0
        
        UpdateSizes()
    }
    
    //MARK: Collection View Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words[section].characters.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return words.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CharacterCapture", forIndexPath: indexPath) as! TutorialCharacterCell
        let characterIndex = words[indexPath.section].characters.startIndex.advancedBy(indexPath.item)
        let character = words[indexPath.section].characters[characterIndex]
        cell.populate(character)
        cell.addEventSubscriber(self, handler: HandleCellEvent)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let tutorialWordCell = cell as! TutorialCharacterCell
        tutorialWordCell.save()
        tutorialWordCell.removeEventSubscriber(self)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SectionHeader", forIndexPath: indexPath)
        case UICollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SectionFooter", forIndexPath: indexPath)
        default:
            assert(false, "Unexpected kind for supplementary element")
        }
    }
    
    func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            let visibleCells = collectionView?.visibleCells()
            if visibleCells != nil {
                for cell in visibleCells! {
                    let pointInCell = recognizer.locationInView(cell)
                    if cell.pointInside(pointInCell, withEvent: nil) {
                        collectionView?.scrollEnabled = false
                        break
                    }
                }
            }
        }
        else {
           collectionView?.scrollEnabled = true
        }
    }
    
    private func HandleCellEvent(cell:TutorialCharacterCell, state:TutorialCharacterCell.CellEventType) {
        if(state == .EndedDrawing && cell.character != nil) {
            unwrittenCharacters.remove(cell.character!)
        }
        else if(state == .Cleared && cell.character != nil) {
            unwrittenCharacters.insert(cell.character!)
        }
        
        finishButton?.enabled = unwrittenCharacters.count == 0
    }
    
    private func updateItemHeight(viewSize:CGSize) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        //var itemHeight = (viewSize.width - (layout.minimumLineSpacing * (words[wordIndex].characters.count - 1))) / words[wordIndex].characters.count
        //itemHeight = min(itemHeight, viewSize.height)
        let itemHeight = viewSize.height
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
    
        let cells = self.collectionView?.visibleCells()
        if(cells != nil) {
            for cell in cells! as! [TutorialCharacterCell] {
                cell.updateSize(itemHeight)
            }
        }
    }
    
    //MARK: Screen Orientation Methods
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        UpdateSizes()
    }
    
    /** The message and item height depend on screen size but when the screen is first shown these sizes are incorrect so we wait a brief period before actually
    updating the sizes of the elements. This function can be called multiple times in the same frame without consequence*/
    private func UpdateSizes() {
        //Don't re-trigger the timer, we set it to nil after it fires
        if _updateSizesTimer == nil || !_updateSizesTimer!.valid {
            _updateSizesTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "HandleDelayUpdateSize:", userInfo: nil, repeats: true)
        }
    }
    
    func HandleDelayUpdateSize(timer:NSTimer) {
        if self.view.frame == CGRectZero {
            return
        }
        
        timer.invalidate()
        UpdateMessages()
        updateItemHeight(collectionView!.bounds.size)
    }
    
    /*override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }*/
    
    //MARK: Rendering
    
    private func UpdateMessages() {
        messageImageView.image = RenderMessage()
    }
    
    private func RenderMessage() -> UIImage? {
        return _messageRenderer!.renderMessage(phrase, imageSize:  CGSize(width: 2048, height: messageImageView.frame.height), lineHeight: messageImageView.frame.size.height * 0.5, backgroundColor: UIColor.clearColor())
    }
    
    //Mark: Analytics
    
    private func LogWordForAnalytics(word:String, isStarting:Bool) {
        if isStarting {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialWordStarted, parameters: ["Word":word])
        }
        else {
             MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialWordFinished, parameters: ["Word":word])
        }
    }
    
    //MARK: Button Handlers
    
    @IBAction func HandleFinishBtn(sender:AnyObject) {
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        atlas?.Save()
        
        _tutorialState?.wordIndex = 0
        //Move to next screen
        _tutorialState?.setTutorialFlag(TutorialState.TutorialFlags.StartingPhrase)
        let postTutorialScreen = storyboard?.instantiateViewControllerWithIdentifier("PostTutorialScreen")
        if postTutorialScreen != nil && _messageRenderer != nil {
            if postTutorialScreen is TutorialPhaseOutroController {
                let tutorialPhraseController = postTutorialScreen as! TutorialPhaseOutroController
                let image = RenderMessage()
                if image != nil {
                    tutorialPhraseController.setMessage(image!)
                }
            }
            
            self.presentViewController(postTutorialScreen!, animated: true, completion: nil)
        }
    }
    
    @IBAction func HandleSkipBtn(sender:AnyObject) {
        let navigationRoot = storyboard?.instantiateViewControllerWithIdentifier("NavigationRoot")
        if navigationRoot != nil {
            self.presentViewController(navigationRoot!, animated: true, completion: nil)
        }
    }
}

class TutorialCharacterCell: UICollectionViewCell {
    enum CellEventType
    {
        case StartedDrawing
        case EndedDrawing
        case Cleared
    }
    
    @IBOutlet var label:UILabel?
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    @IBOutlet var clearButton:UIImageView?
    private var _initialLabelAlpha:CGFloat!
    private var _character:Character?
    
    typealias CellEvent = (cell:TutorialCharacterCell, state:CellEventType) -> Void
    private var _cellEventSubscribers = [Int:CellEvent]()
    
    var character:Character? {
        get {
            return _character
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawCaptureView?.addDrawEventSubscriber(self, handler: handleDrawEvent)
        _initialLabelAlpha = label != nil ? label!.alpha : 0.5
        clearButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleClearBtn:"))
        clearButton?.userInteractionEnabled = true
        clearButton?.hidden = true
    }
    
    func populate(value:Character) {
        label?.text = String(value)
        updateSize(frame.height)
        drawCaptureView?.clear()
        label?.alpha = _initialLabelAlpha
        _character = value
        
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        let characterString = String(value)
        if atlas!.hasGlyphMapping(characterString) {
            let glyphData = atlas!.getGlyphData(characterString)!
            let imageData = glyphData.image as! FontAtlasImage
            let subImage = UIImage(CGImage: CGImageCreateWithImageInRect(imageData.loadedImage!.CGImage, glyphData.imageCoord * imageData.loadedImage!.size)!);
            drawCaptureView?.loadImage(subImage, rect: glyphData.glyphBounds)
            clearButton?.hidden = false
        }
    }
    
    func handleDrawEvent(drawView:UIDrawView, eventType:UIDrawView.DrawEventType) {
        switch(eventType) {
        case .Began:
            UIView.animateWithDuration(0.5, animations: {
                self.label?.alpha = 0.1
            })
            broadcastToSubscribers(CellEventType.StartedDrawing)
        case .Ended:
            save()
            clearButton?.hidden = false
            broadcastToSubscribers(CellEventType.EndedDrawing)
        case .Cleared:
            clearButton?.hidden = true
            label?.alpha = _initialLabelAlpha
            broadcastToSubscribers(CellEventType.Cleared)
        }
    }
    
    func save() {
        if !isEmpty {
            let string = String(_character!)
            drawCaptureView?.save(string, captureType: "Tutorial", saveAtlas: false)
            drawCaptureView?.save(string.lowercaseString, captureType: "Tutorial", saveAtlas: false)
        }
    }
    
    var isEmpty:Bool {
        get {
            return drawCaptureView != nil ? drawCaptureView!.isEmpty : true
        }
    }
    
    func updateSize(size:CGFloat) {
        label?.font = label?.font.fontWithSize(size)
    }
    
    func addEventSubscriber(target:AnyObject, handler:CellEvent) {
        if target.hash != nil {
            _cellEventSubscribers[target.hash!] = handler
        }
    }
    
    func removeEventSubscriber(target:AnyObject) {
        _cellEventSubscribers.removeValueForKey(target.hash)
    }
    
    func handleClearBtn(sender:AnyObject) {
        drawCaptureView?.clear()
    }
    
    private func broadcastToSubscribers(eventType:CellEventType) {
        for subscriber in _cellEventSubscribers.values {
            subscriber(cell: self, state: eventType)
        }
    }
}