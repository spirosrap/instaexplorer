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
        
        name = dictionary[InstaClient.DictionaryKeys.Name] as? String
        media_count = dictionary[InstaClient.DictionaryKeys.MediaCount] as? NSNumber
    }

    static func tagsFromResults(results: [[String : AnyObject]],context: NSManagedObjectContext) -> [Tag] {
        var tags = [Tag]()
        for result in results {
            var dictionary = [String:AnyObject]()
            
            dictionary[InstaClient.DictionaryKeys.Name] = result[InstaClient.JSONResponseKeys.Name]!
            dictionary[InstaClient.DictionaryKeys.MediaCount] = result[InstaClient.JSONResponseKeys.MediaCount]!
            tags.append(Tag(dictionary: dictionary,context: context))
        }

        return tags
    }
    
}