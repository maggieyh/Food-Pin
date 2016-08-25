//
//  ReviewViewController.swift
//  FoodPin_2
//
//  Created by yao  on 5/20/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit


class ReviewViewController: UIViewController {
    var rating: String?
    @IBAction func ratingSelected(sender: UIButton) {
        switch(sender.tag) {
        case 100: rating = "dislike"
        case 200: rating = "good"
        case 300: rating = "great"
        default: break
        }
        
        performSegueWithIdentifier("unwindToDetailView", sender: sender)
    }
    
    //@IBOutlet var ratingStackView: UIStackView!
    @IBOutlet var dislikeImage: UIButton!
    @IBOutlet var goodImage: UIButton!
    @IBOutlet var greatImage: UIButton!
    //to blur the image view
    @IBOutlet var backgroundImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        ratingStackView.transform = CGAffineTransformMakeScale(0.0, 0.0)//scale the stack view when it is first loaded
//        ratingStackView.transform = CGAffineTransformMakeTranslation(0, 500)//move the stck view off screen
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 500)
        
        //dislikeImage.transform = CGAffineTransformConcat(scale, translate)
        dislikeImage.transform = translate
        goodImage.transform = translate
        greatImage.transform = translate
        
        let blurEffect  = UIBlurEffect(style: .Dark)//dark, light, and extra light
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)

    }
    override func viewDidAppear(animated: Bool) {
        //creat growing effect
       UIView.animateWithDuration(1.5, delay: 0.0, options: [], animations: {self.dislikeImage.transform = CGAffineTransformIdentity}, completion: nil)//first kind
        UIView.animateWithDuration(1.5, delay: 0.5, options: [], animations: { self.goodImage.transform = CGAffineTransformIdentity}, completion: nil)
        UIView.animateWithDuration(1.5, delay: 1.0, options: [], animations: { self.greatImage.transform = CGAffineTransformIdentity}, completion: nil)
        
        //second: spring animation
//        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
//            self.ratingStackView.transform = CGAffineTransformIdentity
//        }, completion: nil)
        //Damping takes a value from 0 to 1, and controls how much resistance the spring has when it approaches the end state of an animation. If you want to increase oscillation, set to a lower value. The initialSpringVelocity property specifies the initial spring velocity.
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
