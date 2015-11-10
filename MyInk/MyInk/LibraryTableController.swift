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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        _atlas = (UIApplication.sharedApplication().delegate as! AppDelegate).currentAtlas
        _atlasGlyphs = _atlas?.glyphs
        _atlasGlyphs?.sortInPlace({ $0.mapping <  $1.mapping })
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Flurry.logEvent("Screen Loaded - Library")
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