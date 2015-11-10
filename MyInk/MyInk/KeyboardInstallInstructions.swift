//
//  KeyboardInstallInstructions.swift
//  MyInk
//
//  Created by Galen Ryder on 2015-08-17.
//  Copyright (c) 2015 E-Link. All rights reserved.
//

import UIKit

class KeyboardInstallationInstructions:UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomItem: UIView!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.layoutIfNeeded()
        contentView.frame.size.height = bottomItem.frame.origin.y + bottomItem.frame.height + 8
        scrollView.contentSize = contentView.bounds.size
    }
}