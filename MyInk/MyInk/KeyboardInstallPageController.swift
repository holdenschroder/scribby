//
//  KeyboardInstallPageController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-11-19.
//  Copyright © 2015 E-Link. All rights reserved.
//

import UIKit


class KeyboardInstallPageController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Vars
    
    private var pageViewController: UIPageViewController?
    
    // Initialize it right away here
    private let contentImages = [
        "keyboard_install_1.png",
        "keyboard_install_2.png",
        "keyboard_install_3.png",
        "keyboard_install_4.png",
        "keyboard_install_5.png",
        "keyboard_install_6.png",
        "keyboard_install_7.png",
        "keyboard_install_8.png",
        "keyboard_install_9.png"
    ];
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPageViewController()
        setupPageControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("InstallPageController") as! UIPageViewController
        pageController.dataSource = self
        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        if itemController.itemIndex+1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        if itemIndex < contentImages.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("InstallItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

