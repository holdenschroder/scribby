//
//  PageItemController.swift
//

import UIKit
import QuartzCore

class PageItemController: UIViewController {
    
    // MARK: - Vars
    
    var itemIndex: Int = 0
    var imageName: String = "" {
        didSet {
            if let imageView = contentImageView {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    
    @IBOutlet var contentImageView: UIImageView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        let xBtn = UIButton()
        xBtn.setTitle("x", forState: .Normal)
        xBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        xBtn.frame = CGRectMake(22, 22, 33, 33)
        xBtn.layer.cornerRadius = 3.0
        xBtn.layer.borderWidth = 1.5
        xBtn.layer.borderColor = UIColor.whiteColor().CGColor
        xBtn.layer.backgroundColor = UIColor.blackColor().CGColor
        xBtn.layer.masksToBounds = true
        xBtn.addTarget(self, action: "pressed", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(xBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(itemIndex == 8) {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedKeyboardAllPages)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: - Actions
    
    func pressed() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
}
