//
//  TutorialPhraseController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-09-23.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit
import AVFoundation

class TutorialPhraseController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    fileprivate let phrase:String! = "QUICK BROWN FOX JUMPS\nOVER THE LAZY DOG"
    fileprivate var words:[String]!
    fileprivate let mPhrase:String! = "QUICKBROWNFOXJUMPSOVERTHELAZYDOG"
    fileprivate var mCharacters:[String]!
    
    fileprivate var unwrittenCharacters = Set<Character>()
    fileprivate var _messageRenderer:FontMessageRenderer?
    fileprivate var _tutorialState:TutorialState?
    fileprivate var _updateSizesTimer:Timer?
    fileprivate var _sections:IndexSet!
    fileprivate var wordIndex = 0
    fileprivate var _lastInteractedCell:TutorialCharacterCell?
    
    var audioHelper = AudioHelper()
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var finishButton: UIBarButtonItem!
    @IBOutlet weak var messageImageView:UIImageView!
    
    //MARK: Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.panGestureRecognizer.addTarget(self, action: #selector(TutorialPhraseController.handlePanGesture(_:)))
        words = phrase.components(separatedBy: " ")
        mCharacters = mPhrase.characters.map { String($0) }
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        let fallbackAtlas = (UIApplication.shared.delegate as! AppDelegate).embeddedAtlas
        if(currentAtlas != nil) {
            _messageRenderer = FontMessageRenderer(atlas: currentAtlas!, fallbackAtlas:fallbackAtlas!, watermark: nil)
        }
        
        if _tutorialState == nil {
            _tutorialState = (UIApplication.shared.delegate as! AppDelegate).tutorialState
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 1000.0
        self.automaticallyAdjustsScrollViewInsets = false
        
        let currentAtlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
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
        //finishButton?.enabled = unwrittenCharacters.count == 0
        unwrittenCharacters.removeAll()
        
        UpdateSizes()
    }
    
    //MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mCharacters[wordIndex].characters.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCapture", for: indexPath) as! TutorialCharacterCell
        let characterIndex = mCharacters[wordIndex].characters.index(mCharacters[wordIndex].characters.startIndex, offsetBy: indexPath.item)
        let character = mCharacters[wordIndex].characters[characterIndex]
        cell.populate(character)
        cell.addEventSubscriber(self, handler: HandleCellEvent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tutorialWordCell = cell as! TutorialCharacterCell
        tutorialWordCell.save()
        tutorialWordCell.removeEventSubscriber(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath)
        case UICollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionFooter", for: indexPath)
        default:
            fatalError("Unexpected kind for supplementary element")
       }
    }
    
    func handlePanGesture(_ recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let visibleCells = collectionView?.visibleCells
            if visibleCells != nil {
                for cell in visibleCells! {
                    let pointInCell = recognizer.location(in: cell)
                    if cell.point(inside: pointInCell, with: nil) {
                        collectionView?.isScrollEnabled = false
                        break
                    }
                }
            }
        }
        else {
           collectionView?.isScrollEnabled = true
        }
    }
    
    fileprivate func HandleCellEvent(_ cell:TutorialCharacterCell, state:TutorialCharacterCell.CellEventType) {
        if(state == .endedDrawing && cell.character != nil) {
            unwrittenCharacters.remove(cell.character!)
        }
        else if(state == .cleared && cell.character != nil) {
            unwrittenCharacters.insert(cell.character!)
        }
        
        _lastInteractedCell = cell
    }
    
    fileprivate func updateItemHeight(_ viewSize:CGSize) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemHeight = viewSize.height
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        let cells = self.collectionView?.visibleCells
        if(cells != nil) {
            for cell in cells! as! [TutorialCharacterCell] {
                cell.updateSize(itemHeight)
            }
        }
    }
    
    //MARK: Screen Orientation Methods
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        UpdateSizes()
    }

    fileprivate func UpdateSizes() {
        //Don't re-trigger the timer, we set it to nil after it fires
        if _updateSizesTimer == nil || !_updateSizesTimer!.isValid {
            _updateSizesTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TutorialPhraseController.HandleDelayUpdateSize(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func HandleDelayUpdateSize(_ timer:Timer) {
        if self.view.frame == CGRect.zero {
            return
        }
        timer.invalidate()
        UpdateMessages()
        updateItemHeight(collectionView!.bounds.size)
    }
    
    //MARK: Rendering
    
    fileprivate func UpdateMessages() {
        messageImageView.image = RenderMessage()
    }
    
    fileprivate func RenderMessage() -> UIImage? {
        return _messageRenderer!.render(message: phrase, width: 750, lineHeight: messageImageView.frame.height / 2.25, backgroundColor: UIColor.clear)
    }
    
    //Mark: Analytics
    
    fileprivate func LogWordForAnalytics(_ word:String, isStarting:Bool) {
        if isStarting {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialWordStarted, parameters: ["Word":word])
        }
        else {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialWordFinished, parameters: ["Word":word])
        }
    }
    
    //MARK: Button Handlers
    
    @IBAction func HandleNextBtn(_ sender:AnyObject) {
        audioHelper.playFinSound()
        LogWordForAnalytics(mCharacters[wordIndex], isStarting:false)
        wordIndex += 1
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
            _tutorialState?.setTutorialFlag(TutorialState.TutorialFlags.startingPhrase)
            let postTutorialScreen = storyboard?.instantiateViewController(withIdentifier: "PostTutorialScreen")
            if postTutorialScreen != nil && _messageRenderer != nil {
                if postTutorialScreen is TutorialPhaseOutroController {
                    let tutorialPhraseController = postTutorialScreen as! TutorialPhaseOutroController
                    let image = RenderMessage()
                    if image != nil {
                        tutorialPhraseController.setMessage(image!)
                    }
                }
                self.present(postTutorialScreen!, animated: true, completion: nil)
            }
        }
        let atlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        atlas?.Save()
    }
    
    @IBAction func HandleFinishBtn(_ sender:AnyObject) {
        let atlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        atlas?.Save()
        
        _tutorialState?.wordIndex = 0
        _tutorialState?.setTutorialFlag(TutorialState.TutorialFlags.startingPhrase)
        let postTutorialScreen = storyboard?.instantiateViewController(withIdentifier: "PostTutorialScreen")
        if postTutorialScreen != nil && _messageRenderer != nil {
            if postTutorialScreen is TutorialPhaseOutroController {
                MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialFinished)
                let tutorialPhraseController = postTutorialScreen as! TutorialPhaseOutroController
                let image = RenderMessage()
                if image != nil {
                    tutorialPhraseController.setMessage(image!)
                }
            }
            self.present(postTutorialScreen!, animated: true, completion: nil)
        }
    }
    
    @IBAction func HandleSkipBtn(_ sender:AnyObject) {
        let alert = UIAlertController(title: "Skip Tutorial?", message: "Are you sure that you want to skip? Your font will be reset to the default.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Skip Cancelled")
        }
        alert.addAction(cancelAction)
        let SkipAction = UIAlertAction(title: "Skip", style: .default) { (action) in
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventTutorialSkipped)
            MyInkAnalytics.EndTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: nil)
            UserDefaults.standard.set(true, forKey: SharedMyInkValues.kDefaultsUserHasBoarded)
            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationRoot") as UIViewController, animated: true, completion: nil)
        }
        alert.addAction(SkipAction)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.audioHelper.playSkipSound()
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func HandleClearBtn(_ sender: AnyObject) {
        if(_lastInteractedCell != nil) {
            _lastInteractedCell?.clear()
        }
    }
}

class TutorialCharacterCell: UICollectionViewCell {
    enum CellEventType
    {
        case startedDrawing
        case endedDrawing
        case cleared
    }
    
    @IBOutlet var label:UILabel?
    @IBOutlet var drawCaptureView:UIDrawCaptureView?
    @IBOutlet var clearButton:UIButton?
    @IBOutlet var saveButton:UIButton?
    
    fileprivate var _initialLabelAlpha:CGFloat!
    fileprivate var _character:Character?
    
    typealias CellEvent = (_ cell:TutorialCharacterCell, _ state:CellEventType) -> Void
    fileprivate var _cellEventSubscribers = [Int:CellEvent]()
    
    var character:Character? {
        get {
            return _character
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawCaptureView?.addDrawEventSubscriber(self, handler: handleDrawEvent)
        _initialLabelAlpha = label != nil ? label!.alpha : 0.1
        clearButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TutorialCharacterCell.handleClearBtn(_:))))
        clearButton?.isUserInteractionEnabled = true
        clearButton?.isHidden = true
        saveButton?.isUserInteractionEnabled = true
        saveButton?.isHidden = true
    }
    
    func populate(_ value:Character) {
        label?.text = String(value)
        updateSize(frame.height)
        drawCaptureView?.clear()
        label?.alpha = _initialLabelAlpha
        _character = value

        /*
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
        */
    }
    
    func handleDrawEvent(_ drawView:UIDrawView, eventType:UIDrawView.DrawEventType) {
        switch(eventType) {
        case .began:
            UIView.animate(withDuration: 0.25, animations: {
                self.label?.alpha = 0.05
            })
            broadcastToSubscribers(CellEventType.startedDrawing)
        case .ended:
            save()
            clearButton?.isHidden = false
            saveButton?.isHidden = false
            broadcastToSubscribers(CellEventType.endedDrawing)
        case .cleared:
            clearButton?.isHidden = true
            saveButton?.isHidden = true
            label?.alpha = _initialLabelAlpha
            broadcastToSubscribers(CellEventType.cleared)
        }
    }
    
    func save() {
        if !isEmpty {
            let string = String(_character!)
            drawCaptureView?.save(string, captureType: "Tutorial", saveAtlas: false)
            drawCaptureView?.save(string.lowercased(), captureType: "Tutorial", saveAtlas: false)
        }
    }
    
    func clear() {
        drawCaptureView?.clear()
    }
    
    var isEmpty:Bool {
        get {
            return drawCaptureView != nil ? drawCaptureView!.isEmpty : true
        }
    }
    
    func updateSize(_ size:CGFloat) {
        label?.font = label?.font.withSize(size)
    }
    
    func addEventSubscriber(_ target:AnyObject, handler:@escaping CellEvent) {
        if target.hash != nil {
            _cellEventSubscribers[target.hash!] = handler
        }
    }
    
    func removeEventSubscriber(_ target:AnyObject) {
        _cellEventSubscribers.removeValue(forKey: target.hash)
    }
    
    func handleClearBtn(_ sender:AnyObject) {
        drawCaptureView?.clear()
    }
    
    fileprivate func broadcastToSubscribers(_ eventType:CellEventType) {
        for subscriber in _cellEventSubscribers.values {
            subscriber(self, eventType)
        }
    }
}
