//
//  CaptureCharacterSelectController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-06-03.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class CaptureCharacterSelectController:UIViewController {
    @IBOutlet var imageView:UIImageView?
    @IBOutlet var toleranceSlider:UISlider?
    @IBOutlet var selectionView:UIDrawSelectionView?
    @IBOutlet var debugView:UIView?
    @IBOutlet var continueButton:UIBarItem?
    
    fileprivate var baseImage:CIImage?
    fileprivate var modifiedImage:UIImage?
    fileprivate var isolationFilter:CIKernel?
    fileprivate var maskFilter:CIKernel?
    fileprivate var inkColor:CIColor = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var toleranceValue:Float = 0.2
    var _mAtlasGlyph: FontAtlasGlyph?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isolationFilter = LoadFilter("isolationfilter")
        maskFilter = LoadFilter("maskfilter")
        toleranceSlider?.isContinuous = false
        toleranceSlider?.value = toleranceValue
        
        selectionView?.addOnChangeListener(handleSelectionChanged)
    }
    
    fileprivate func LoadFilter(_ path:String) -> CIColorKernel {
        let filterPath = Bundle.main.path(forResource: path, ofType: "cikernel")
        let filterCode = try? String(contentsOfFile: filterPath!, encoding: String.Encoding.utf8)
        return CIColorKernel(string: filterCode!)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        modifiedImage = ProcessImage(baseImage!)
        imageView?.image = modifiedImage
        selectionView?.clearImage()
        continueButton?.isEnabled = false
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParentViewController {
            baseImage = nil
            modifiedImage = nil
            isolationFilter = nil
            maskFilter = nil
            imageView?.image = nil
            selectionView?.clearImage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let error = NSError(domain: "Memory Warning", code: 0, userInfo: nil)
        Flurry.logError(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect, message: "Memory Warning", error: error)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is SetupCharacterController {
            let setupCharacterController = segue.destination as! SetupCharacterController
            if((_mAtlasGlyph) != nil) {
                setupCharacterController._mAtlasGlyph = _mAtlasGlyph
            }
            
            let croppedImage = selectionView!.CropImageBySelection(imageView!)
            var croppedMask = selectionView!.CropImageBySelection(selectionView!)
        
            let imageRect = croppedImage!.extent
            var maskRect = croppedMask!.extent
            let maskToImageScale = CGSize(width: imageRect.width / maskRect.width, height: imageRect.height / maskRect.height)
            croppedMask = croppedMask!.applying(CGAffineTransform(scaleX: maskToImageScale.width, y: maskToImageScale.height))
            maskRect = croppedMask!.extent
            croppedMask = croppedMask!.applying(CGAffineTransform(translationX: -maskRect.origin.x, y: -maskRect.origin.y))
        
            let maskedOutput = maskFilter!.apply(withExtent: imageRect, roiCallback: ROICallback, arguments: [croppedImage!, croppedMask!])
            if(maskedOutput != nil) {
                maskRect = selectionView!.GetContentRect(true)
            
                //Compensate for mirroring issue
                let context = CIContext(options: nil)
                let mask_cg = context.createCGImage(maskedOutput!, from: maskedOutput!.extent)
            
                setupCharacterController.LoadCharacter(UIImage(cgImage: mask_cg!))
            }
        }
    }
    
    func handleSelectionChanged(_ view:UIDrawSelectionView, cleared:Bool) {
        continueButton?.isEnabled = !cleared
    }
    
    func LoadImage(_ image:CIImage, inkColor:CIColor? = nil) {
        baseImage = image;
        //let ci_baseImage = CIImage(CGImage: baseImage!.CGImage)
        if inkColor != nil {
            self.inkColor = inkColor!
        }
        else {
            self.inkColor = ImageCropUtility.FindInkColor(baseImage!)
        }
    }
    
    func ProcessImage(_ image:CIImage?) -> UIImage? {
        if(image != nil) {
            let context = CIContext(options: nil)
            
            let rect = image!.extent
            
            let outputImage = isolationFilter!.apply(withExtent: rect, roiCallback: ROICallback, arguments: [image!, inkColor, CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), toleranceValue])
            let imageRef = context.createCGImage(outputImage!, from: rect)
            //let originalOrientation = imageView!.image!.imageOrientation
            //let originalScale = imageView!.image!.scale
            return UIImage(cgImage: imageRef!)//, scale: originalScale, orientation: originalOrientation)
        }
        
        return nil
    }
    
    fileprivate func ROICallback(_ index:Int32, rect:CGRect) -> CGRect
    {
        return rect;
    }
    
    @IBAction func HandleToleranceSlider(_ sender: UISlider) {
        toleranceValue = sender.value
        modifiedImage = ProcessImage(baseImage!)
        imageView?.image = modifiedImage
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
