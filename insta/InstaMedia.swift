//
//  InstaMedia.swift
//  instaplaces
//
//  Created by Spiros Raptis on 06/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(InstaMedia)

class InstaMedia: NSManagedObject {
    @NSManaged var text:String?
    @NSManaged var fullname:String?
    @NSManaged var thumbnailPath:String?
    @NSManaged var imagePath:String?
    @NSManaged var mediaID:String?
    
    @NSManaged var username:String?
    @NSManaged var profileImagePath:String?
    @NSManaged var userID:String?
    

    
    @NSManaged var link:String?
    @NSManaged var instaLocation: InstaLocation?
    @NSManaged var location: Location?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    
    init(dictionary: [String : AnyObject],context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("InstaMedia", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        text = dictionary["text"] as? String
        username = dictionary["username"] as? String
        fullname = dictionary["fullname"] as? String
        userID = dictionary["userID"] as? String
        mediaID = dictionary["mediaID"] as? String
        thumbnailPath = dictionary["thumbnailPath"] as? String
        imagePath = dictionary["imagePath"] as? String
        profileImagePath = dictionary["profileImagePath"] as? String
        link = dictionary["link"] as? String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func imagesFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext) -> [InstaMedia] {
        var images = [InstaMedia]()
        
        for result in results {

            var dictionary = [String:AnyObject]()
            
            if ( result["type"]! as! String == "image"){
                
                dictionary["username"] = result["user"]!.valueForKey("username")!
                
                dictionary["profileImagePath"] = result["user"]!.valueForKey("profile_picture")!
                dictionary["thumbnailPath"] = result["images"]!.valueForKey("thumbnail")!.valueForKey("url")!
                dictionary["imagePath"] = result["images"]!.valueForKey("standard_resolution")!.valueForKey("url")!
                dictionary["link"] = result["link"]!
                
                dictionary["userID"] = result["user"]!.valueForKey("id")!
                println(dictionary["userID"])
                dictionary["mediaID"] = result["id"]!
                println(dictionary["mediaID"])
                
                if let text: AnyObject = result["caption"]!.valueForKey("text"){
                    dictionary["text"] = text
                }
                
                if let fullname: AnyObject = result["caption"]!.valueForKey("from")!.valueForKey("full_name"){
                    dictionary["fullname"] = fullname
                }
                
            }
            
            if(dictionary["imagePath"] != nil){ //Don't create and entry to images if the InstaMedia doesn't have an imagePath(deleted image)
                images.append(InstaMedia(dictionary: dictionary,context: context))
            }
            
        }
        
//        if !images.isEmpty {
//            for i in images{
//                if i.link == nil{
//                    println(i.fullname)
//                    println(i.imagePath)
//                    println(i.profileImagePath)
//                    println(i.text)
//                    println(i.thumbnailPath)
//                    println(i.username)
//                }
//            }
//        }

        
        return images
    }
    
    var image: UIImage? {
        get {
            return InstaClient.Caches.imageCache.imageWithIdentifier(imagePath!)
        }
        set {
            
            InstaClient.Caches.imageCache.storeImage(image, withIdentifier: imagePath!)
        }
    }
    
    var thumbnail: UIImage? {
        get {
            return InstaClient.Caches.imageCache.imageWithIdentifier(thumbnailPath!)
        }
        set {
            InstaClient.Caches.imageCache.storeImage(image, withIdentifier: thumbnailPath!)
        }
    }
    
    var profileImage: UIImage? {
        get {
            return InstaClient.Caches.imageCache.imageWithIdentifier(profileImagePath!)
        }
        set {
            InstaClient.Caches.imageCache.storeImage(image, withIdentifier: profileImagePath!)
        }
    }



}
