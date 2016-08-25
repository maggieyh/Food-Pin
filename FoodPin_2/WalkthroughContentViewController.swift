//
//  WalkthroughContentViewController.swift
//  FoodPin_2
//
//  Created by yao  on 5/25/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit


class WalkthroughContentViewController: UIViewController {
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contenLabel: UILabel!
    @IBOutlet var contenImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var forwardButton: UIButton!
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        
        switch index {
        case 0...1:
            let pageViewController = parentViewController as! WalkthroughPageViewController
            pageViewController.forward(index)
        case 2:
            dismissViewControllerAnimated(true, completion: nil)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "hasViewedWalkthrough")
            
            dismissViewControllerAnimated(true, completion: nil)
        default: break
        }
    }
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        headingLabel.text = heading
        contenLabel.text = content
        contenImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        
        switch index {
        case 0...1: forwardButton.setTitle("NEXT", forState: .Normal)
        case 2: forwardButton.setTitle("DONE", forState: .Normal)
        default: break
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
