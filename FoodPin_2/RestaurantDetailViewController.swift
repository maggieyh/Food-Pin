//
//  RestaurantDetailViewController.swift
//  FoodPin_2
//
//  Created by yao  on 5/19/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit

class RestaurantDetailViewController:UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet var restaurantImageView: UIImageView!
//    @IBOutlet var restaurantName: UILabel!
//    @IBOutlet var restaurantType: UILabel!
//    @IBOutlet var restaurantLocation: UILabel!
    @IBOutlet var tableView: UITableView!
    var restaurant: Restaurant!
   
    //unwind segue and data passing
    @IBOutlet var ratingButton: UIButton!
    
    //unwind segue, and updat the image with data passed from restaurant view controller
    @IBAction func close(segue: UIStoryboardSegue) {
        if let ReviewViewController = segue.sourceViewController as? ReviewViewController {
            if let rating = ReviewViewController.rating {
                ratingButton.setImage(UIImage(named: rating), forState: UIControlState.Normal)
                restaurant.rating = rating
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                }
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destinationViewController as! MapViewController
            destinationController.restaurant = restaurant
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        restaurantImageView.image = UIImage(data:  restaurant.image!)
        
        //Change color of tableView
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.2)
        
        //Remove the separators of empty rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //Set the title of the navigation bar
        title = restaurant.name
        
        //Eabling self sizing cells
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //set the rating of the restaurant
        if let rating = restaurant.rating where rating != "" {
            ratingButton.setImage(UIImage(named: restaurant.rating!), forState: .Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RestaurantDetailTableViewCell

        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "Type"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "Been here"
            if let isVisited = restaurant.isVisited?.boolValue {
            cell.valueLabel.text = isVisited ? "Yes, I've been here before" : "No"
            }
        case 4:
            cell.fieldLabel.text = "Phone"
            cell.valueLabel.text = restaurant.phoneNumber
        case 5:
            cell.fieldLabel.text = "Rating"
            cell.valueLabel.text = restaurant.rating
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor() //make the cells transparent
        
        return cell
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
