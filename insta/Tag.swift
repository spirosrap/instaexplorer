//
//  Tags.swift
//  instaplaces
//
//  Created by Spiros Raptis on 15/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import UIKit



class Tag {
    var name:String!
    var media_count:Int!
    
    init(var name:String, var media_count:Int){
        self.name = name
        self.media_count = media_count
    }

    static func tagsFromResults(results: [[String : AnyObject]]) -> [Tag] {
        var tags = [Tag]()
        
        for result in results {
            tags.append(Tag(name: result["name"]! as! String,media_count: result["media_count"]! as! Int))
        }

        return tags
    }
    
}