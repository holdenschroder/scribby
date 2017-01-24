//
//  GuidelinesPageItemController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-11.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit
import QuartzCore

class GuidelinesPageItemController: UIViewController {
    
    // MARK: - Vars
    
    var itemIndex: Int = 0
    var imageName: String = "" {
        didSet {
            if let imageView = contentImageView {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    var stringName: String = "" {
        didSet {
            if let labelView = contentLabel {
                labelView.text = stringName
            }
        }
    }

    
    @IBOutlet var contentImageView: UIImageView?
    @IBOutlet weak var contentLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
        contentLabel.text = stringName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let xBtn = UIButton()
        xBtn.setTitle("X", for: UIControlState())
        xBtn.setTitleColor(UIColor.black, for: UIControlState())
        xBtn.frame = CGRect(x: 22, y: 22, width: 33, height: 33)
        xBtn.layer.cornerRadius = 3.0
        xBtn.layer.borderWidth = 1.5
        xBtn.layer.borderColor = UIColor.black.cgColor
        xBtn.layer.backgroundColor = UIColor.white.cgColor
        xBtn.layer.masksToBounds = true
        xBtn.addTarget(self, action: #selector(GuidelinesPageItemController.HandleXBtn), for: .touchUpInside)
        self.view.addSubview(xBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if(itemIndex == 4) {
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

