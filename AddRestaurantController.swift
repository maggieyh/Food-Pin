//
//  AddRestaurantController.swift
//  FoodPin_2
//
//  Created by yao  on 5/20/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddRestaurantController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate { // to interact with the image picker interface
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    

    var isVisited: Bool? = true
    var restaurant: Restaurant!
    
    @IBAction func saveNewPlace(sender: UIButton) {
        let name = nameTextField.text
        let type = typeTextField.text
        let location = locationTextField.text
        let phoneNumber = phoneNumberTextField.text
        if name == "" || type == "" || location == "" || phoneNumber == "" {
            let alerMessage = UIAlertController(title: "Oops", message: "We can't proceed becus one of the fields is blank. Please not that all fields are required", preferredStyle: .Alert)
            alerMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alerMessage, animated: true, completion: nil)
        } else {
            print("Name: \(name) \nType: \(type) \nLocation: \(location) \nPhoneNumber: \(phoneNumber) \nHave you been here: \(isVisited)")
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: managedObjectContext) as! Restaurant
                restaurant.name = name!
                restaurant.type = type!
                restaurant.location = location!
                restaurant.phoneNumber = phoneNumber!
                if let restaurantImage = imageView.image {
                    restaurant.image = UIImagePNGRepresentation(restaurantImage)
                }
                restaurant.isVisited = isVisited
                saveRecordToCloud(restaurant)
                do {
                    try managedObjectContext.save()
                    
                } catch {
                    print(error)
                    return
                }
            }
            dismissViewControllerAnimated(true, completion: nil)
            
            
        }
        
    }
   
    
    @IBAction func toggleBeenHere(sender: UIButton) {
        if sender == yesButton {
            sender.backgroundColor = sender.backgroundColor == UIColor.redColor() ? UIColor.lightGrayColor() : UIColor.redColor()
            noButton.backgroundColor = noButton.backgroundColor == UIColor.redColor() ? UIColor.lightGrayColor() : UIColor.redColor()
        } else if sender == noButton {
            sender.backgroundColor = sender.backgroundColor == UIColor.redColor() ? UIColor.lightGrayColor() : UIColor.redColor()
            yesButton.backgroundColor = yesButton.backgroundColor == UIColor.redColor() ? UIColor.lightGrayColor() : UIColor.redColor()
        }
    
        isVisited =  yesButton.backgroundColor == UIColor.redColor() ? true : false
            
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //detect the touch and load the photo library
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) { //chekc if user allow to access the photo library
                //to access the camera, use ".Camera"
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true,completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //get the slected photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        
        //The item parameter corresponds to First item, attribute corresponds to the item after the dot in First item, relatedBy corresponds to Relation, toItem corresponds to Second Item, attribute corresponds to the item after the dot in Second item, multiplier corresponds to Multiplier, and constant corresponds to Constant.
        
       // By default, the constraint is not activated after instantiation. You have to set its active property to true in order to activate it.
        let leadingConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: imageView.superview, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        leadingConstraint.active = true
        
        let trailingConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: imageView.superview, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        trailingConstraint.active = true
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: imageView.superview, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        topConstraint.active = true
        
        let bottomConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: imageView.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        bottomConstraint.active = false
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
        
    }
    
    func saveRecordToCloud(restaurant: Restaurant!) -> Void {
        //Prepate the record to save
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phoneNumber, forKey: "phone")
        
        //Resize the image
        let originalImage = UIImage(data: restaurant.image!)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024/originalImage.size.width : 1.0
        let scaledImage = UIImage(data: restaurant.image!, scale: scalingFactor)!
        
        //write the image to local file for temporary use
        let imageFilePath = NSTemporaryDirectory() + restaurant.name
        UIImageJPEGRepresentation(scaledImage, 0.8)?.writeToFile(imageFilePath, atomically: true) //compress the imgae data and call write to file method to save the compressed image as a file
        
        //Create image asset for upload
        let imageFileURL = NSURL(fileURLWithPath: imageFilePath)
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        //Get the public icloud database
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        
        //Save the record to icloud
        publicDatabase.saveRecord(record, completionHandler: {(record: CKRecord?, error: NSError?) -> Void in
            //remove temp file
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imageFilePath)
                
            } catch {
                print("failed to save record to the cloud: \(error)")
            }
        })
        
        
    }
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell..
     
     return cell
     }
     */
    
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
