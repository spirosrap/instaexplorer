//
//  Tags.swift
//  instaexplorer
//  The Object for saving tags.
//  Created by Spiros Raptis on 15/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Tag)


class Tag:NSManagedObject {
    @NSManaged var name:String?
    @NSManaged var media_count:NSNumber?
    @NSManaged var media:[InstaMedia]?
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    
    
    init(dictionary: [String : AnyObject],context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Tag", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary["name"] as? String
        media_count = dictionary["media_count"] as? NSNumber
    }

    static func tagsFromResults(results: [[String : AnyObject]],context: NSManagedObjectContext) -> [Tag] {
        var tags = [Tag]()
        for result in results {
            var dictionary = [String:AnyObject]()
            
            dictionary["name"] = result["name"]!
            dictionary["media_count"] = result["media_count"]!
            tags.append(Tag(dictionary: dictionary,context: context))
        }

        return tags
    }
    
}