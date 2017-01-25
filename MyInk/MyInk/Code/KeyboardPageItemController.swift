//
//  KeyboardPageItemController.swift
//

import UIKit
import QuartzCore

class KeyboardPageItemController: UIViewController {
    
    // MARK: - Vars
    
    var itemIndex: Int = 0
    var imageName: String = "" {
        didSet {
            contentImageView?.image = UIImage(named: imageName)
        }
    }
    
    @IBOutlet var contentImageView: UIImageView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let xBtn = UIButton()
        xBtn.setTitle("X", for: UIControlState())
        xBtn.setTitleColor(UIColor.white, for: UIControlState())
        xBtn.frame = CGRect(x: 22, y: 22, width: 33, height: 33)
        xBtn.layer.cornerRadius = 3.0
        xBtn.layer.borderWidth = 1.5
        xBtn.layer.borderColor = UIColor.white.cgColor
        xBtn.layer.backgroundColor = UIColor.black.cgColor
        xBtn.layer.masksToBounds = true
        xBtn.addTarget(self, action: #selector(KeyboardPageItemController.HandleXBtn), for: .touchUpInside)
        self.view.addSubview(xBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        if(itemIndex == 8) {
            MyInkAnalytics.TrackEvent(SharedMyInkValues.kEventScreenLoadedKeyboardAllPages)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Actions
    
    func HandleXBtn() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}
