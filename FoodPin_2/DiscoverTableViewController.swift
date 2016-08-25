//
//  DiscoverTableViewController.swift
//  FoodPin_2
//
//  Created by yao  on 6/4/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    var restaurants:[CKRecord] = []
    @IBOutlet var spinner:UIActivityIndicatorView!
    

    var imageCache:NSCache = NSCache()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        getRecordsFromCloud()
        
       
        spinner.activityIndicatorViewStyle = .Gray
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.startAnimating()
        
        //UIRefreshControl for implementing the pull-to-refresh
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.redColor()
        refreshControl?.tintColor = UIColor.blueColor()
        refreshControl?.addTarget(self, action: "getRecordsFromCloud", forControlEvents: UIControlEvents.ValueChanged)
        
       
        
    }
    

    func getRecordsFromCloud() {
        
        //remove existing records before refreshing
        restaurants.removeAll()
        tableView.reloadData()
        
        //fetch data using convenience api
        let cloudContainer = CKContainer.defaultContainer()
        let publicDatabase = cloudContainer.publicCloudDatabase
        //prepare the query
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //Optional API
        //Create the query operation with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name","location", "type"] //specify the field to fetch
        queryOperation.queuePriority = .VeryHigh
        queryOperation.resultsLimit = 50
        
        //executed every time a record returned
        queryOperation.recordFetchedBlock = { (record:CKRecord!) -> Void in
            if let restaurantRecord = record {
                self.restaurants.append(restaurantRecord)
            }
        }
        
        
        //executed after all records are fetched
        queryOperation.queryCompletionBlock = { (cursor:CKQueryCursor?, error:NSError?) -> Void in
            
            //cursor object to indicate if there are more results to fetch
                if (error != nil) {
                    print("Failed to get data from iCloud -\(error!.localizedDescription)")
                    return
                }
                
                print("Successfully retrieve the data from icloud")
                self.refreshControl?.endRefreshing()
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                    
                }
            
            }
            //Execute the query
            publicDatabase.addOperation(queryOperation)
        }
//        performQuery is limited
//        publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {
//            (results, error) -> Void in
//            
//            if error != nil {
//                print(error)
//                return
//            }
//            
//            if let results = results {
//                print("Completed the download of Restaurant data")
//                self.restaurants = results
//                
//                NSOperationQueue.mainQueue().addOperationWithBlock() {
//                    self.tableView.reloadData()
//                }
//            }
//        })
//        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DiscoverTableViewCell  //downcasting

        // Configure the cell...
        let restaurant = restaurants[indexPath.row] //ckrecord is a dictionary arrarys
        cell.nameLabel.text = restaurant.objectForKey("name") as? String
        cell.locationLabel.text = restaurant.objectForKey("location") as? String
        cell.typeLabel.text = restaurant.objectForKey("type") as? String
        print(cell.typeLabel.text)
        //Set default image
        cell.thumbnailimageView.image = UIImage(named: "photoalbum")
        
    
        //Check if the image is stored in cache
        if let imageFileURL = imageCache.objectForKey(restaurant.recordID) as? NSURL {
            // Fetch image from cache 
            print("get image from cache")
            cell.thumbnailimageView?.image = UIImage(data: NSData(contentsOfURL: imageFileURL)!)
        } else {
            
            // Fetch image from cloud in background | lazy loading
            let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .VeryHigh
            
            
            //similar to CKQueryOpereation, execute when the record is available
            fetchRecordsImageOperation.perRecordCompletionBlock = {(record: CKRecord?, recordID: CKRecordID?, error: NSError?) -> Void in
                if (error != nil) {
                    print("Failed to get image: \(error!.localizedDescription)")
                    return
                }
                
                if let restaurantRecord = record {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if let imageAsset = restaurantRecord.objectForKey("image") as? CKAsset {
                            cell.thumbnailimageView.image = UIImage(data: NSData(contentsOfURL: imageAsset.fileURL)!)
                            
                            cell.nameLabel.text = restaurant.objectForKey("name") as? String
                            cell.locationLabel.text = restaurant.objectForKey("location") as? String
                            cell.typeLabel.text = restaurant.objectForKey("type") as? String
                        
                        }
                    }
                }
            }
            
            publicDatabase.addOperation(fetchRecordsImageOperation)
        }
        
        return cell
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
