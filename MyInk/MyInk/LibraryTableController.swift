//
//  GlyphMappingTableController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-15.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class LibraryCollectionController:UICollectionViewController {
    private var _atlas:FontAtlas?
    private var _atlasGlyphs:[FontAtlasGlyph]?
    private var _mAtlasGlyphToPass: FontAtlasGlyph!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        _atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        _atlasGlyphs = _atlas?.glyphs
        if(_atlasGlyphs!.count > 0) {
            _atlasGlyphs?.sortInPlace({ $0.mapping <  $1.mapping })
        }
        else {
            let alert = UIAlertController(title: "Empty", message: "There is nothing in your library - go and capture some characters!", preferredStyle: .Alert)
            let AlrightAction = UIAlertAction(title: "Alright!", style: .Default) { (action) in
                self.navigationController?.popViewControllerAnimated(true)
            }
            alert.addAction(AlrightAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
        self.collectionView!.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryList)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.destinationViewController is LibraryItemController {
            let detailVC = segue.destinationViewController as! LibraryItemController;
            detailVC._mAtlasGlyph = _mAtlasGlyphToPass
        }
    }
    
    //MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        _mAtlasGlyphToPass = _atlasGlyphs![indexPath.row]
        self.performSegueWithIdentifier("captureSingleItemFromLibrary", sender: self)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _atlasGlyphs!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LibraryCell", forIndexPath: indexPath) as! LibraryCollectionCell
        cell.populate(_atlasGlyphs![indexPath.item])
        return cell
    }
}

class LibraryCollectionCell:UICollectionViewCell {
    @IBOutlet var glyphImageView:UIImageView?
    @IBOutlet var label:UILabel?
    private var _glyphData:FontAtlasGlyph?
    
    func populate(glyphData:FontAtlasGlyph) {
        _glyphData = glyphData
        label?.text = _glyphData?.mapping
        glyphImageView?.image = (_glyphData?.image as! FontAtlasImage).loadedImage
        var contentsRect = _glyphData!.imageCoord
        contentsRect.size = CGSize(width: _glyphData!.imageCoord.width, height: _glyphData!.imageCoord.height * _glyphData!.glyphBounds.height)
        glyphImageView?.layer.contentsRect = contentsRect
    }
}