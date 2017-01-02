//
//  GuidelinesPageController.swift
//  MyInk
//
//  Created by Jesse Scott on 2015-12-11.
//  Copyright © 2015 E-Link. All rights reserved.
//


import UIKit


class GuidelinesPageController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Vars
    
    fileprivate var pageViewController: UIPageViewController?
        fileprivate let contentImages = [
        "glyph_guidelines.png",
        "glyph_guidelines_ascender.png",
        "glyph_guidelines_baseline.png",
        "glyph_guidelines_descender.png"
    ];
    fileprivate let contentStrings = [
        "The blue guidelines help us to register where our character will sit as we creating our letters.",
        "The ascender is the highest limit where the upward tail on letters like h, l, t, b, d, and k can draw.",
        "The baseline is the line upon which most letters 'sit' and below which descenders extend.",
        "The  descender line is the lowest limit for letters like g, q, and y."
    ];

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPageViewController()
        setupPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    fileprivate func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "InstallPageController") as! UIPageViewController
        pageController.dataSource = self
        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    fileprivate func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = SharedMyInkValues.MyInkDarkColor //UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! GuidelinesPageItemController
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! GuidelinesPageItemController
        if itemController.itemIndex+1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    fileprivate func getItemController(_ itemIndex: Int) -> GuidelinesPageItemController? {
        if itemIndex < contentImages.count {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "GuidelinesPageItemController") as! GuidelinesPageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            pageItemController.stringName = contentStrings[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}


