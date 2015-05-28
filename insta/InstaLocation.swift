//
//  InstaLocation.swift
//  instaexplorer
//  This is for the specific location object the api sometimes associates with an images
//  It is not used in the project, but it can be used later for more advanced location based searching.
//  Created by Spiros Raptis on 05/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import CoreData

@objc(InstaLocation)


class InstaLocation: NSManagedObject{
    
    @NSManaged var latitude:NSNumber
    @NSManaged var id: String
    @NSManaged var longitude:NSNumber
    @NSManaged var name: String
    @NSManaged var location:Location?
    @NSManaged var instaMedia: [InstaMedia]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("InstaLocation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        name = dictionary[InstaClient.DictionaryKeys.Name] as! String
        id = dictionary[InstaClient.DictionaryKeys.id] as! String
        longitude = dictionary[InstaClient.DictionaryKeys.Longitude] as! Double
        latitude = dictionary[InstaClient.DictionaryKeys.Latitude] as! Double
        
    }


    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func locationsFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext) -> [InstaLocation] {
        var locations = [InstaLocation]()
        
        for result in results {
            locations.append(InstaLocation(dictionary: result,context: context))
        }
        
        return locations
    }

}
