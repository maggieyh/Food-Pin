//
//  WalkthroughPageViewController.swift
//  FoodPin_2
//
//  Created by yao  on 5/25/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit


//The data source object should conform to the UIPageViewControllerDataSource protocol and implement the following required methods:

//pageViewController(_:viewControllerBeforeViewController:)
//pageViewController(_:viewControllerAfterViewController:)


//The UIPageViewControllerDataSource protocol provides the following method to support a standard page indicator:
//
//presentationCountForPageViewController - implements this method to return the total number of dots (or pages) to be shown in the indicator
//presentationIndexForPageViewController - implements this method to return the index of the selected item


class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageHeadings = ["Personalize", "Locate", "Discover"]
    var pageImages = ["foodpin-intro-1", "foodpin-intro-2", "foodpin-intro-3"]
    var pageContent = ["Pin your favorite restaurants and creat your own food guide", "Search and locate your favorite restaurant on Maps", "Find restuarants pinned by your firends and other foodies around the world"]
    
    func forward(index: Int) {
        if let nextViewController = viewControllerAtIndex(index + 1) {
            setViewControllers([nextViewController], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        
        if index == NSNotFound || index < 0 || index >= pageHeadings.count {
            return nil
        }
        
        //Create a new view controller and pass suitable data
        if let pageContentViewController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentViewController") as? WalkthroughContentViewController {
            
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        //we have set a storyboard ID for the view controller when designing the user interface. The ID is used as reference for creating the view controller instance. To instantiate a view controller in storyboard, you call the instantiateViewControllerWithIdentifier method with a specific storyboard ID. The method returns an optional object corresponding to the storyboard ID. This is why we use as? to downcast the object to WalkthroughContentViewController. Following the instantiation, we assign the content view controller with specific image, heading, content, and index.
        

        return nil
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return pageHeadings.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        if let pageContentViewController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentViewController") as? WalkthroughContentViewController {
//            
//            return pageContentViewController.index
//        }
//        
//        return 0
//    }
//    because use custom page control
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set the data source to itself
        dataSource = self
        
        //Create the first walkthrough screen
        if let startingViewController = viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
