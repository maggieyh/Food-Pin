//
//  RestaurantTableViewController.swift
//  FoodPin_2
//
//  Created by yao  on 5/16/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    //The fetched results controller is specially designed for managing the results returned from a Core Data fetch request, and providing data for a table view. It monitors changes to objects in the managed object context and reports changes in the result set to its delegate.
    //The NSFetchedResultsControllerDelegate protocol provides methods to notify its delegate whenever there are any changes in the controller's fetch resulrts.
    var fetchResultController: NSFetchedResultsController!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthrough")
        
        if hasViewedWalkthrough {
            return
        }
        
        if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughController") as? WalkthroughPageViewController {
            presentViewController(pageViewController, animated: true, completion: nil)
        }
    }
    @IBAction func unwindToHOmeScreen(segue: UIStoryboardSegue) {
        
    }
    
    var restaurants:[Restaurant] = []
    
    var searchController:UISearchController!
    
    var searchResults: [Restaurant] = []
    
    func filterContentForSearchText(searchText: String) {
        searchResults = restaurants.filter({ (restaurant:Restaurant) -> Bool in
            let nameMatch = restaurant.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) //rangeofString -> examine if the restaurant name contains the search text
            let nameMatch_2 = restaurant.location.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            return nameMatch != nil || nameMatch_2 != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            tableView.reloadData()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
    }  //call evertime
    
    override func viewDidLoad() {

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        super.viewDidLoad()
        
        //adding a search bar
        searchController = UISearchController(searchResultsController: nil) //creat a instance, and nil means the search results be displayed in the same view
        tableView.tableHeaderView = searchController.searchBar //add the search bar on the table View
        
        // Remove the title of the back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        //Enabling self sizing cell
        tableView.estimatedRowHeight = 20.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let fetchRequest = NSFetchRequest(entityName: "Restaurant")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                restaurants = fetchResultController.fetchedObjects as! [Restaurant]
            } catch {
                print(error)
            }
        }
        
        //
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false // The dimsBackgroundDuringPresentation property controls whether the underlying content is dimmed during a search
        
        //customize
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.barTintColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        
    }//call only once
    
    //called when the fetched results controller is about to start processing the content change.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    //when any change is made, this method is called, determine the type of operation and then proceed
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
            
        case .Delete:
            if let _indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let _indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
        default:
            tableView.reloadData()
        }
        
        restaurants = controller.fetchedObjects as! [Restaurant]
    }
    //after change is done, this method is called, and will animate the change subsequently
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.active {
            return searchResults.count
        } else {
            return restaurants.count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RestaurantTableViewCell   //downcasting
        
        
        let restaurant = (searchController.active) ? searchResults[indexPath.row] : restaurants[indexPath.row] // check if researched, retrieve the restaurant from the search result rather than the restaruants array
        
        //configure the cell....
        cell.nameLabel.text = restaurant.name
        
        //becus the image is now stored as an "NSData" object
        cell.thumbnailImageView.image = UIImage(data: restaurant.image!)
        
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        /* one way to configure attribute of image aside from adding runtime attribute
        cell.thumbnailImageView.layer.cornerRadius = 25
        cell.thumbnailImageView.clipsToBounds = true
        */
        //becuz isVisited is NSNumber type
        if let isVisited = restaurant.isVisited?.boolValue {
            cell.accessoryType = isVisited ? .Checkmark : .None
        }
        
        return cell
    }
    
    //if searching ,no swipe and delete
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        } else {
            return true
        }
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//        //creat option menu as an action sheet
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .ActionSheet)
//        
//        /* preferredStyle: .Alert -> pop up in the middle ......
//        eg.
//        let alertController = UIAlertController(title: "Welcome", message: "hello", preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title:"ok", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(alertController, animated: true , completion: nil )
//        */
//        
//        //add actions to the menu
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)//handler -> code happens afer the cancelAction initiated
//        optionMenu.addAction(cancelAction)
//        
//        let callActionHandler = { (action:UIAlertAction!) -> Void in
//            let alertMessage = UIAlertController(title: "Service Unavailable", message: "fature is unavailable", preferredStyle: .Alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(alertMessage, animated: true, completion: nil)
//        }
//        
//        let callAction = UIAlertAction(title: "Call" + "123-\(indexPath.row)", style: .Default, handler: callActionHandler)
//        optionMenu.addAction(callAction)
//        
//        
//        let isVisitedAction = UIAlertAction(title: "I've been here", style: .Default, handler: {
//            (action: UIAlertAction) -> Void in
//            
//            let cell = tableView.cellForRowAtIndexPath(indexPath)//retrieve the selected cell
//            cell?.accessoryType = .Checkmark
//            self.restaurantIsVisited[indexPath.row] = true
//            })
//        optionMenu.addAction(isVisitedAction)
//        
//       let noVisitedAction = UIAlertAction(title: "actually havent visited", style: .Default, handler: {
//            (action: UIAlertAction) -> Void in
//            
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            cell?.accessoryType = .None
//            self.restaurantIsVisited[indexPath.row] = false
//            
//        })
//        optionMenu.addAction(noVisitedAction)
//        
//       /* optionMenu.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))*/
//        //display the menu
//
//        self.presentViewController(optionMenu, animated: true, completion: nil)
//    }
    
    
    override func tableView(tableVeiw: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
           //delete the row from data source
            let oldValue = restaurants.count
            restaurants.removeAtIndex(indexPath.row)
            
            
           // tableView.reloadData()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)//.Right,Left,Top,Fade
            
            let alertMessage = UIAlertController(title: "totla item:", message: "\(oldValue) -> \(restaurants.count)", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
        }
    }//if this method is built, the "delete" button will automatically be there
    //the method support 2 types of editingsyle: delete, insert
    
    
    //when tableView(_:editActionsForRowAtIndexPath:) is implemented, the table view will no lonfer generate the delete button automatically-> antoehr delete action
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //UITableViewRowAction is similar to UIAlerAction
        //Social Sharing button
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Share", handler: { (action, indexPath) -> Void in
            
            let defaultText = "Just checking in at " + self.restaurants[indexPath.row].name
            
            if let imageToShare = UIImage(data: self.restaurants[indexPath.row].image!) {
                //it is possible that the image is failed to load so optional~
                let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)//sharing message by creating an instance of UIActivityViewContorller with the message object
                self.presentViewController(activityController, animated: true, completion: nil)
            }
        })
        
        
        
        // Delete button
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action, indexPath) -> Void in
            
            //Delete the row from the database
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                
                let restaurantToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Restaurant
                managedObjectContext.deleteObject(restaurantToDelete)
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
              }
            
            })
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        return [deleteAction, shareAction]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow { //* make sure retrieve the right index.row
                let destinationController = segue.destinationViewController as! RestaurantDetailViewController
                destinationController.restaurant = (searchController.active) ? searchResults[indexPath.row] : restaurants[indexPath.row] //**
                
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
