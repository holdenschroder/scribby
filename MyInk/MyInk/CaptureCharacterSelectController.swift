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
    
    private var baseImage:CIImage?
    private var modifiedImage:UIImage?
    private var isolationFilter:CIKernel?
    private var maskFilter:CIKernel?
    private var inkColor:CIColor = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var toleranceValue:Float = 0.2
    var _mAtlasGlyph: FontAtlasGlyph?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isolationFilter = LoadFilter("isolationfilter")
        maskFilter = LoadFilter("maskfilter")
        toleranceSlider?.continuous = false
        toleranceSlider?.value = toleranceValue
        
        selectionView?.addOnChangeListener(handleSelectionChanged)
    }
    
    private func LoadFilter(path:String) -> CIColorKernel {
        let filterPath = NSBundle.mainBundle().pathForResource(path, ofType: "cikernel")
        let filterCode = try? String(contentsOfFile: filterPath!, encoding: NSUTF8StringEncoding)
        return CIColorKernel(string: filterCode!)!
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.title = ""

        modifiedImage = ProcessImage(baseImage!)
        imageView?.image = modifiedImage
        selectionView?.clearImage()
        continueButton?.enabled = false
        
        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParentViewController() {
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
        let error = NSError?()
        Flurry.logError(SharedMyInkValues.kEventScreenLoadedCaptureCharacterSelect, message: "Memory Warning", error: error)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.destinationViewController is SetupCharacterController {
            let setupCharacterController = segue.destinationViewController as! SetupCharacterController
            if((_mAtlasGlyph) != nil) {
                setupCharacterController._mAtlasGlyph = _mAtlasGlyph
            }
            
            let croppedImage = selectionView!.CropImageBySelection(imageView!)
            var croppedMask = selectionView!.CropImageBySelection(selectionView!)
        
            let imageRect = croppedImage!.extent
            var maskRect = croppedMask!.extent
            let maskToImageScale = CGSize(width: imageRect.width / maskRect.width, height: imageRect.height / maskRect.height)
            croppedMask = croppedMask!.imageByApplyingTransform(CGAffineTransformMakeScale(maskToImageScale.width, maskToImageScale.height))
            maskRect = croppedMask!.extent
            croppedMask = croppedMask!.imageByApplyingTransform(CGAffineTransformMakeTranslation(-maskRect.origin.x, -maskRect.origin.y))
        
            let maskedOutput = maskFilter!.applyWithExtent(imageRect, roiCallback: ROICallback, arguments: [croppedImage!, croppedMask!])
            if(maskedOutput != nil) {
                maskRect = selectionView!.GetContentRect(true)
            
                //Compensate for mirroring issue
                let context = CIContext(options: nil)
                let mask_cg = context.createCGImage(maskedOutput!, fromRect: maskedOutput!.extent)
            
                setupCharacterController.LoadCharacter(UIImage(CGImage: mask_cg))
            }
        }
    }
    
    func handleSelectionChanged(view:UIDrawSelectionView, cleared:Bool) {
        continueButton?.enabled = !cleared
    }
    
    func LoadImage(image:CIImage, inkColor:CIColor? = nil) {
        baseImage = image;
        //let ci_baseImage = CIImage(CGImage: baseImage!.CGImage)
        if inkColor != nil {
            self.inkColor = inkColor!
        }
        else {
            self.inkColor = ImageCropUtility.FindInkColor(baseImage!)
        }
    }
    
    func ProcessImage(image:CIImage?) -> UIImage? {
        if(image != nil) {
            let context = CIContext(options: nil)
            
            let rect = image!.extent
            
            let outputImage = isolationFilter!.applyWithExtent(rect, roiCallback: ROICallback, arguments: [image!, inkColor, CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), toleranceValue])
            let imageRef = context.createCGImage(outputImage!, fromRect: rect)
            //let originalOrientation = imageView!.image!.imageOrientation
            //let originalScale = imageView!.image!.scale
            return UIImage(CGImage: imageRef)//, scale: originalScale, orientation: originalOrientation)
        }
        
        return nil
    }
    
    private func ROICallback(index:Int32, rect:CGRect) -> CGRect
    {
        return rect;
    }
    
    @IBAction func HandleToleranceSlider(sender: UISlider) {
        toleranceValue = sender.value
        modifiedImage = ProcessImage(baseImage!)
        imageView?.image = modifiedImage
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}