//
//  TutorialPhraseController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-23.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit

class TutorialPhraseController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    private let phrase:String! = "QUICK BROWN FOX JUMPS\n OVER THE LAZY DOG"
    private var words:[String]!

    private let mPhrase:String! = "QUICKBROWNFOXJUMPSOVERTHELAZYDOG"
    private var mCharacters:[String]!
    
    private var unwrittenCharacters = Set<Character>()
    private var _messageRenderer:FontMessageRenderer?
    private var _tutorialState:TutorialState?
    private var _updateSizesTimer:NSTimer?
    private var _sections:NSIndexSet!
    private var wordIndex = 0

    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var finishButton: UIBarButtonItem!
    @IBOutlet weak var messageImageView:UIImageView!
    
    //MARK: Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
        words = phrase.componentsSeparatedByString(" ")
        mCharacters = mPhrase.characters.map { String($0) }
        
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

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
        if _tutorialState != nil {
            wordIndex = Int(_tutorialState!.wordIndex)
            if wordIndex >= mCharacters.count {
                wordIndex = 0
            }
        }
        finishButton?.enabled = unwrittenCharacters.count == 0
        unwrittenCharacters.removeAll()
        
        UpdateSizes()
    }
    
    //MARK: Collection View Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mCharacters[wordIndex].characters.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return mCharacters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CharacterCapture", forIndexPath: indexPath) as! TutorialCharacterCell
        let characterIndex = mCharacters[wordIndex].characters.startIndex.advancedBy(indexPath.item)
        let character = mCharacters[wordIndex].characters[characterIndex]
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
            fatalError("Unexpected kind for supplementary element")
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
        if(wordIndex < mCharacters.count) {
            finishButton?.enabled = false
        }
        else {
             finishButton?.enabled = true
        }
        //finishButton?.enabled = unwrittenCharacters.count == 0
    }
    
    private func updateItemHeight(viewSize:CGSize) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
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
    
    //MARK: Rendering
    
    private func UpdateMessages() {
        messageImageView.image = RenderMessage()
    }
    
    private func RenderMessage() -> UIImage? {
        return _messageRenderer!.renderMessage(phrase, imageSize:  CGSize(width: 2048, height: messageImageView.frame.height), lineHeight: messageImageView.frame.size.height * 0.33, backgroundColor: UIColor.clearColor())
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
    
    @IBAction func HandleNextBtn(sender:AnyObject) {
        LogWordForAnalytics(mCharacters[wordIndex], isStarting:false)
        ++wordIndex
        if wordIndex < mCharacters.count {
            LogWordForAnalytics(mCharacters[wordIndex], isStarting:true)
            updateItemHeight(collectionView!.bounds.size)
            collectionView.reloadData()
            unwrittenCharacters.removeAll()
            UpdateMessages()
            _tutorialState?.wordIndex = Int32(wordIndex)
        }
        else {
            _tutorialState?.wordIndex = 0
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
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        atlas?.Save()
    }
    
    @IBAction func HandleFinishBtn(sender:AnyObject) {
        let atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        atlas?.Save()
        
        _tutorialState?.wordIndex = 0
        _tutorialState?.setTutorialFlag(TutorialState.TutorialFlags.StartingPhrase)
        let postTutorialScreen = storyboard?.instantiateViewControllerWithIdentifier("PostTutorialScreen")
        if postTutorialScreen != nil && _messageRenderer != nil {
            if postTutorialScreen is TutorialPhaseOutroController {
                MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialFinished)
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
        let alert = UIAlertController(title: "Skip Tutorial?", message: "Are you sure that you want to skip? Your font will be reset to the default.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Skip Cancelled")
        }
        alert.addAction(cancelAction)
        let SkipAction = UIAlertAction(title: "Skip", style: .Default) { (action) in
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialSkipped)
            MyInkAnalytics.EndTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
            self.presentViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationRoot") as UIViewController, animated: true, completion: nil)
        }
        alert.addAction(SkipAction)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
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
    @IBOutlet var clearButton:UIButton?
    @IBOutlet var saveButton:UIButton?
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
        saveButton?.userInteractionEnabled = true
        saveButton?.hidden = true
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
            saveButton?.hidden = false
        }
    }
    
    func handleDrawEvent(drawView:UIDrawView, eventType:UIDrawView.DrawEventType) {
        switch(eventType) {
        case .Began:
            UIView.animateWithDuration(0.25, animations: {
                self.label?.alpha = 0.0
            })
            broadcastToSubscribers(CellEventType.StartedDrawing)
        case .Ended:
            save()
            clearButton?.hidden = false
            saveButton?.hidden = false
            broadcastToSubscribers(CellEventType.EndedDrawing)
        case .Cleared:
            clearButton?.hidden = true
            saveButton?.hidden = true
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