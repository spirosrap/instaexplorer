//
//  InstaMedia.swift
//  instaexplorer
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
    @NSManaged var favorite:NSNumber? // I cannot create a Bool and use it in Core data. http://stackoverflow.com/questions/24333507/swift-coredata-can-not-set-a-bool-on-nsmanagedobject-subclass-bug
    @NSManaged var username:String?
    @NSManaged var profileImagePath:String?
    @NSManaged var userID:String?
    
    @NSManaged var link:String?
    @NSManaged var instaLocation: InstaLocation?
    @NSManaged var location: Location?
    @NSManaged var tag:Tag?
    
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
        instaLocation = dictionary["instaLocation"] as? InstaLocation
        favorite = dictionary["favorite"] as? NSNumber
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func imagesFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext) -> [InstaMedia] {
        var images = [InstaMedia]()
        
        for result in results {

            var dictionary = [String:AnyObject]()
            
            if ( result["type"]! as! String == "image"){
                dictionary["favorite"] = 0 //Default is not a favorite
                dictionary["username"] = result["user"]!.valueForKey("username")!
                
                dictionary["profileImagePath"] = result["user"]!.valueForKey("profile_picture")!
                dictionary["thumbnailPath"] = result["images"]!.valueForKey("thumbnail")!.valueForKey("url")!
                dictionary["imagePath"] = result["images"]!.valueForKey("standard_resolution")!.valueForKey("url")!
                dictionary["link"] = result["link"]!
                
                dictionary["userID"] = result["user"]!.valueForKey("id")!
                dictionary["mediaID"] = result["id"]!

                
                if let text: AnyObject = result["caption"]!.valueForKey("text"){
                    dictionary["text"] = text
                }
                
                if let fullname: AnyObject = result["caption"]!.valueForKey("from")!.valueForKey("full_name"){
                    dictionary["fullname"] = fullname
                }
                
                if let lat =  result["location"]!.valueForKey("latitude") as? Double,let lng = result["location"]!.valueForKey("longitude") as? Double,let name = result["location"]!.valueForKey("name") as? String,let id = result["location"]!.valueForKey("id") as? Double {
                    
                    dictionary["instaLocation"] = InstaLocation(dictionary: ["name":name as String,"id":"\(id as Double)","longitude":lng as Double,"latitude":lat as Double], context: context)
                }
                
            }
            
            if(dictionary["imagePath"] != nil){ //Don't create and entry to images if the InstaMedia doesn't have an imagePath(deleted image)
                images.append(InstaMedia(dictionary: dictionary,context: context))
            }
            
        }
        return images
    }
    
    static func copy(var media:InstaMedia,context: NSManagedObjectContext) -> InstaMedia{
        
        var dictionary = [String:AnyObject]()

        dictionary["text"] = media.text
        dictionary["username"] = media.username
        dictionary["fullname"] = media.fullname
        dictionary["userID"] = media.userID
        dictionary["mediaID"] = media.mediaID
        dictionary["thumbnailPath"] = media.thumbnailPath
        dictionary["imagePath"] = media.imagePath
        dictionary["profileImagePath"] = media.profileImagePath
        dictionary["link"] = media.link
        dictionary["instaLocation"] = media.instaLocation
        dictionary["favorite"] = media.favorite
        
        return InstaMedia(dictionary: dictionary,context: context)
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
