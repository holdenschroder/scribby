//
//  SettingsController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-02.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit

class SettingsController: UIViewController {
    

    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        readWriteVersion()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBarHidden = false


    }
    
    
    func readWriteVersion() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                let info = "Version: \(version) Build: (\(build))"
                print(info)
                versionLabel.text = info
            }
        }
    }
    

    
}

