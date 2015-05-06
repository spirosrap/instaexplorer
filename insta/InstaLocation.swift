//
//  InstaLocation.swift
//  instaplaces
//
//  Created by Spiros Raptis on 05/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation

struct InstaLocation {
    var latitude:Double
    var id: String
    var longitude:Double
    var name: String
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        name = dictionary["name"] as! String
        id = dictionary["id"] as! String
        longitude = dictionary["longitude"] as! Double
        latitude = dictionary["latitude"] as! Double
        
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func locationsFromResults(results: [[String : AnyObject]]) -> [InstaLocation] {
        var locations = [InstaLocation]()
        
        for result in results {
            locations.append(InstaLocation(dictionary: result))
        }
        
        return locations
    }

}
