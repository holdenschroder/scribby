//
//  GlyphMappingTableController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-07-15.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class LibraryCollectionController:UICollectionViewController {
    fileprivate var _atlas:FontAtlas?
    fileprivate var _atlasGlyphs:[FontAtlasGlyph]?
    fileprivate var _mAtlasGlyphToPass: FontAtlasGlyph!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        _atlas = (UIApplication.shared.delegate as! AppDelegate).currentAtlas
        _atlasGlyphs = _atlas?.glyphs
        if(_atlasGlyphs!.count > 0) {
            _atlasGlyphs?.sort(by: { $0.mapping <  $1.mapping })
        }
        else {
            let alert = UIAlertController(title: "Empty", message: "There is nothing in your library - go and capture some characters!", preferredStyle: .alert)
            let AlrightAction = UIAlertAction(title: "Alright!", style: .default) { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(AlrightAction)
            self.present(alert, animated: true, completion: nil)
        }

        
        self.collectionView!.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedLibraryList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is LibraryItemController {
            let detailVC = segue.destination as! LibraryItemController;
            detailVC._mAtlasGlyph = _mAtlasGlyphToPass
        }
    }
    
    //MARK: Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _mAtlasGlyphToPass = _atlasGlyphs![indexPath.row]
        self.performSegue(withIdentifier: "captureSingleItemFromLibrary", sender: self)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _atlasGlyphs!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath) as! LibraryCollectionCell
        cell.populate(_atlasGlyphs![indexPath.item])
        return cell
    }
}

class LibraryCollectionCell:UICollectionViewCell {
    @IBOutlet var glyphImageView:UIImageView?
    @IBOutlet var label:UILabel?
    fileprivate var _glyphData:FontAtlasGlyph?
    
    func populate(_ glyphData:FontAtlasGlyph) {
        _glyphData = glyphData
        label?.text = _glyphData?.mapping
        glyphImageView?.image = (_glyphData?.image as! FontAtlasImage).loadedImage
        var contentsRect = _glyphData!.imageCoord
        contentsRect.size = CGSize(width: _glyphData!.imageCoord.width, height: _glyphData!.imageCoord.height * _glyphData!.glyphBounds.height)
        glyphImageView?.layer.contentsRect = contentsRect
    }
}
