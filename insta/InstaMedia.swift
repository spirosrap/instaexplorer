//
//  InstaMedia.swift
//  instaexplorer
//  THe object for the images of instagram
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

        text = dictionary[InstaClient.DictionaryKeys.Text] as? String
        username = dictionary[InstaClient.DictionaryKeys.Username] as? String
        fullname = dictionary[InstaClient.DictionaryKeys.Fullname] as? String
        userID = dictionary[InstaClient.DictionaryKeys.UserID] as? String
        mediaID = dictionary[InstaClient.DictionaryKeys.MediaID] as? String
        thumbnailPath = dictionary[InstaClient.DictionaryKeys.ThumbnailPath] as? String
        imagePath = dictionary[InstaClient.DictionaryKeys.ImagePath] as? String
        profileImagePath = dictionary[InstaClient.DictionaryKeys.ProfileImagePath] as? String
        link = dictionary[InstaClient.DictionaryKeys.Link] as? String
        instaLocation = dictionary[InstaClient.DictionaryKeys.InstaLocation] as? InstaLocation
        favorite = dictionary[InstaClient.DictionaryKeys.Favorite] as? NSNumber
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func imagesFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext) -> [InstaMedia] {
        var images = [InstaMedia]()
        
        for result in results {
            var dictionary = [String:AnyObject]()
            
            if ( result[InstaClient.JSONResponseKeys.Type]! as! String == InstaClient.JSONResponseKeys.Image){
                dictionary[InstaClient.DictionaryKeys.Favorite] = 0 //Default is not a favorite
                dictionary[InstaClient.DictionaryKeys.Username] = result[InstaClient.JSONResponseKeys.User]!.valueForKey(InstaClient.JSONResponseKeys.Username)!
                
                dictionary[InstaClient.DictionaryKeys.ProfileImagePath] = result[InstaClient.JSONResponseKeys.User]!.valueForKey(InstaClient.JSONResponseKeys.ProfilePicture)!
                dictionary[InstaClient.DictionaryKeys.ThumbnailPath] = result[InstaClient.JSONResponseKeys.Images]!.valueForKey(InstaClient.JSONResponseKeys.Thumbnail)!.valueForKey(InstaClient.JSONResponseKeys.Url)!
                dictionary[InstaClient.DictionaryKeys.ImagePath] = result[InstaClient.JSONResponseKeys.Images]!.valueForKey(InstaClient.JSONResponseKeys.standardResolution)!.valueForKey(InstaClient.JSONResponseKeys.Url)!
                dictionary[InstaClient.DictionaryKeys.Link] = result[InstaClient.JSONResponseKeys.Link]!
                
                dictionary[InstaClient.DictionaryKeys.UserID] = result[InstaClient.JSONResponseKeys.User]!.valueForKey(InstaClient.JSONResponseKeys.id)!
                dictionary[InstaClient.DictionaryKeys.MediaID] = result[InstaClient.JSONResponseKeys.id]!

                
                if let text: AnyObject = result[InstaClient.JSONResponseKeys.Caption]!.valueForKey(InstaClient.JSONResponseKeys.Text){
                    dictionary[InstaClient.DictionaryKeys.Text] = text
                }
                
                if let fullname: AnyObject = result[InstaClient.JSONResponseKeys.Caption]!.valueForKey(InstaClient.JSONResponseKeys.From)!.valueForKey(InstaClient.JSONResponseKeys.Fullname){
                    dictionary[InstaClient.DictionaryKeys.Fullname] = fullname
                }
                
                if let lat =  result[InstaClient.JSONResponseKeys.Location]!.valueForKey(InstaClient.JSONResponseKeys.Latitude) as? Double,let lng = result[InstaClient.JSONResponseKeys.Location]!.valueForKey(InstaClient.JSONResponseKeys.Longitude) as? Double,let name = result[InstaClient.JSONResponseKeys.Location]!.valueForKey(InstaClient.JSONResponseKeys.Name) as? String,let id = result[InstaClient.JSONResponseKeys.Location]!.valueForKey(InstaClient.JSONResponseKeys.id) as? Double {
                    
                    dictionary[InstaClient.DictionaryKeys.InstaLocation] = InstaLocation(dictionary: [InstaClient.JSONResponseKeys.Name : name as String,InstaClient.JSONResponseKeys.id:"\(id as Double)",InstaClient.JSONResponseKeys.Longitude:lng as Double,InstaClient.JSONResponseKeys.Latitude:lat as Double], context: context)
                }
                
            }
            
            if(dictionary[InstaClient.DictionaryKeys.ImagePath] != nil){ //Don't create and entry to images if the InstaMedia doesn't have an imagePath(deleted image)
                images.append(InstaMedia(dictionary: dictionary,context: context))
            }
        }
        return images
    }
    
    static func copy(media:InstaMedia,context: NSManagedObjectContext) -> InstaMedia{
        
        var dictionary = [String:AnyObject]()

        dictionary[InstaClient.DictionaryKeys.Text] = media.text
        dictionary[InstaClient.DictionaryKeys.Username] = media.username
        dictionary[InstaClient.DictionaryKeys.Fullname] = media.fullname
        dictionary[InstaClient.DictionaryKeys.UserID] = media.userID
        dictionary[InstaClient.DictionaryKeys.MediaID] = media.mediaID
        dictionary[InstaClient.DictionaryKeys.ThumbnailPath] = media.thumbnailPath
        dictionary[InstaClient.DictionaryKeys.ImagePath] = media.imagePath
        dictionary[InstaClient.DictionaryKeys.ProfileImagePath] = media.profileImagePath
        dictionary[InstaClient.DictionaryKeys.Link] = media.link
        dictionary[InstaClient.DictionaryKeys.InstaLocation] = media.instaLocation
        dictionary[InstaClient.DictionaryKeys.Favorite] = media.favorite
        
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
