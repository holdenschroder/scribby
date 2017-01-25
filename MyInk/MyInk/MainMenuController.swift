//
//  MainMenuController.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-11.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class MainMenuController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureView: CaptureWordSelectController!
    
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var libraryBtn: UIButton!
    @IBOutlet weak var tutorialBtn: UIButton!
    
    var audioHelper = AudioHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureView = storyboard?.instantiateViewController(withIdentifier: "CaptureView") as? CaptureWordSelectController
        
        writeBtn.setImage(UIImage(named: "icon_compose_tapped"), for: .selected)
        createBtn.setImage(UIImage(named: "icon_touch_tapped"), for: .selected)
        libraryBtn.setImage(UIImage(named: "icon_library_tapped"), for: .selected)
        tutorialBtn.setImage(UIImage(named: "icon_tutorial_tapped"), for: .selected)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        writeBtn.isSelected = false
        createBtn.isSelected = false
        libraryBtn.isSelected = false
        tutorialBtn.isSelected = false

        MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedMainMenu)

        handleLaunchToURL()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if let inHierarchy = navigationController?.viewControllers.contains(self) {
            if inHierarchy {
                handleLaunchToURL()
            }
        }
    }

    private func handleLaunchToURL() {
        _ = navigationController?.popToViewController(self, animated: false)
        var pathComponents = SharedMyInkValues.appOpenTargetURLComponents
        if pathComponents.count > 1 && pathComponents[0] == "tutorials" {
            pathComponents = Array(pathComponents[1..<pathComponents.count])
            SharedMyInkValues.appOpenTargetURLComponents = pathComponents
            HandleTutorialButtonAction(self)
        }
    }
    
    //MARK: Button Handlers
    
    
    @IBAction func HandleWriteButtonAction(_ sender: AnyObject) {
        audioHelper.playClickSound()
        writeBtn.isSelected = true
        let vc = storyboard?.instantiateViewController(withIdentifier: "Compose") as? ComposeMessageController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleCreateButtonAction(_ sender: AnyObject) {
        audioHelper.playClickSound()
        createBtn.isSelected = true
        let vc = storyboard?.instantiateViewController(withIdentifier: "Capture") as? CaptureTouchController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleLibraryButtonAction(_ sender: AnyObject) {
        audioHelper.playClickSound()
        libraryBtn.isSelected = true
        let vc = storyboard?.instantiateViewController(withIdentifier: "Library") as? LibraryCollectionController
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func HandleTutorialButtonAction(_ sender: AnyObject) {
        audioHelper.playClickSound()
        tutorialBtn.isSelected = true
        let vc = storyboard?.instantiateViewController(withIdentifier: "Instructions") as? InstallationInstructions
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    
    @IBAction func openCamera(_ sender: UIButton) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            DispatchQueue.main.async(execute: {
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imgPicker, animated: true, completion: nil)
            })
        }
        else //Load Test Image
        {
            showCaptureView(UIImage(named: "CapturePositioningTest")!)
        }
        
    }
    
    @IBAction func openPhraseCapture(_ sender:AnyObject) {
        let tutorialState = (UIApplication.shared.delegate as! AppDelegate).tutorialState
        tutorialState?.wordIndex = 0
        MyInkAnalytics.StartTimedEvent(SharedMyInkValues.kEventTutorialFirstPhrase, parameters: ["Resuming":String(Int(tutorialState!.wordIndex) > 0)])
        present(UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "TutorialIntro") as UIViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        let imageSize = image.size
        var imageTransform:CGAffineTransform = CGAffineTransform.identity
        //Build a transform to offset and rotate the rect depending on the orientation
        let imageOrientation = image.imageOrientation
        switch(imageOrientation)
        {
        case UIImageOrientation.downMirrored:
            fallthrough
        case UIImageOrientation.down:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: imageSize.height)
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI))
        case UIImageOrientation.leftMirrored:
            fallthrough
        case UIImageOrientation.left:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: 0)
            imageTransform = imageTransform.rotated(by: CGFloat(M_PI_2))
        case UIImageOrientation.rightMirrored:
            fallthrough
        case UIImageOrientation.right:
            imageTransform = imageTransform.translatedBy(x: 0, y: imageSize.height)
            imageTransform = imageTransform.rotated(by: CGFloat(-M_PI_2))
        default:
            break
        }
        
        //Compensate for Mirrored orientations
        switch(imageOrientation)
        {
        case UIImageOrientation.upMirrored:
            fallthrough
        case UIImageOrientation.downMirrored:
            imageTransform = imageTransform.translatedBy(x: imageSize.width, y: 0)
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.leftMirrored:
            fallthrough
        case UIImageOrientation.rightMirrored:
            imageTransform = imageTransform.translatedBy(x: imageSize.height, y: 0)
            imageTransform = imageTransform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(imageSize.width), height: Int(imageSize.height),
            bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
        ctx.concatenate(imageTransform);
        switch (imageOrientation) {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .right:
            fallthrough
        case .rightMirrored:
            ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: imageSize.height,height: imageSize.width));
            
        default:
            ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: imageSize.width,height: imageSize.height));
        }
        
        let cgimg = ctx.makeImage();
        let img = UIImage(cgImage: cgimg!)//UIImage imageWithCGImage:cgimg]
        
        picker.dismiss(animated: true, completion: nil)
        showCaptureView(img)
    }
    
    func showCaptureView(_ image:UIImage) {
        self.captureView.loadImage(image)
        self.show(self.captureView, sender: self)
    }
    
    //MARK: Interface Orientation
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}
