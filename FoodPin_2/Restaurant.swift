//
//  Restaurant.swift
//  FoodPin_2
//
//  Created by yao  on 5/19/16.
//  Copyright © 2016 yao . All rights reserved.
//

import Foundation
import CoreData

//Model objects that tie into in the Core Data framework are known as managed objects.
//change to "managed object class"

//managed object is a subclass of NSManagedObject

class Restaurant: NSManagedObject{
    //add the @NSManaged keyword before each property definition that corresponds to the attribute of the Restaurant entity.
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var location: String
    @NSManaged var phoneNumber: String
    
    //optional attribute
    @NSManaged var image: NSData? //Binary data
    @NSManaged var isVisited: NSNumber? //Core Data does not have Boolean type for managed objects,NSNumber uses a non-zero value to represent true, while a zero value means false.
    @NSManaged var rating: String?
   
    

}