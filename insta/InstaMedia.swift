//
//  InstaMedia.swift
//  instaplaces
//
//  Created by Spiros Raptis on 06/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation

struct InstaMedia {
    var text:String?
    var username:String?
    var fullname:String?

    var thumbnailPath:String?
    var imagePath:String?
    var profileImagePath:String?
    var link:String?
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        text = dictionary["text"] as? String
        username = dictionary["username"] as? String
        fullname = dictionary["fullname"] as? String
        
        thumbnailPath = dictionary["thumbnailPath"] as? String
        imagePath = dictionary["imagePath"] as? String
        profileImagePath = dictionary["profileImagePath"] as? String
        link = dictionary["link"] as? String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func imagesFromResults(results: [[String : AnyObject]]) -> [InstaMedia] {
        var images = [InstaMedia]()
        
        for result in results {

            var dictionary = [String:AnyObject]()
            
            if ( result["type"]! as! String == "image"){
                
                dictionary["username"] = result["caption"]!.valueForKey("from")!.valueForKey("username")!
                dictionary["profileImagePath"] = result["caption"]!.valueForKey("from")!.valueForKey("profile_picture")!
                dictionary["thumbnailPath"] = result["images"]!.valueForKey("thumbnail")!.valueForKey("url")!
                dictionary["imagePath"] = result["images"]!.valueForKey("standard_resolution")!.valueForKey("url")!
                dictionary["link"] = result["link"]!
                
                if let text: AnyObject = result["caption"]!.valueForKey("text"){
                    dictionary["text"] = text
                }
                
                if let fullname: AnyObject = result["caption"]!.valueForKey("from")!.valueForKey("full_name"){
                    dictionary["fullname"] = fullname
                }
                
            }
            
            if(dictionary["imagePath"] != nil){ //Don't create and entry to images if the InstaMedia doesn't have an imagePath(deleted image)
                images.append(InstaMedia(dictionary: dictionary))
            }
            
        }
        
        if !images.isEmpty {
            for i in images{
                if i.link == nil{
                    println(i.fullname)
                    println(i.imagePath)
                    println(i.profileImagePath)
                    println(i.text)
                    println(i.thumbnailPath)
                    println(i.username)
                }
            }
        }

        
        return images
    }

}
