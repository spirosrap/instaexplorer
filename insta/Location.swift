//
//  Location.swift
//  instaexplorer
//  The location I need to associate with a set of media. It can be associated with an InstaLocation as well.
//  Created by Spiros Raptis on 19/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import CoreData

@objc(Location)
class Location:NSManagedObject{
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var instaLocations: [InstaLocation]?
    @NSManaged var instaMedia: [InstaMedia]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        latitude = dictionary[Keys.Latitude] as! NSNumber
        longitude = dictionary[Keys.Longitude] as! NSNumber
    }
   
}