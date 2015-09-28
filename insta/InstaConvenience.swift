//
//  InstaConvenience.swift
//  instaexplorer
//
//  Created by Spiros Raptis on 05/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import Foundation
import CoreData
// MARK: - Convenient Resource Methods

extension InstaClient {
    
    var accessTokenfilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("accessToken").path!
    }

    
    func loginWithToken(hostViewController: UIViewController,completionHandler:(success: Bool,errorString:String?) -> Void){
        if(NSKeyedUnarchiver.unarchiveObjectWithFile(accessTokenfilePath) == nil){
            getAccessToken(hostViewController, completionHandler: { (success, accessToken, errorString) -> Void in
                if success {
                    self.accessToken = accessToken
                    NSKeyedArchiver.archiveRootObject(accessToken!, toFile: self.accessTokenfilePath)
                    completionHandler(success: success, errorString: nil)
                }else{
                    completionHandler(success: false, errorString: "Couldn't get access Token")
                }
            })
        }else{
            self.accessToken = NSKeyedUnarchiver.unarchiveObjectWithFile(accessTokenfilePath) as? String
            completionHandler(success: true, errorString: nil)
        }
    }
    
    func getAccessToken(hostViewController: UIViewController, completionHandler: (success: Bool,accessToken:String?, errorString: String?) -> Void) {
        
        let modifiedURLString = String(format:"%@?client_id=%@&redirect_uri=%@&response_type=token", InstaClient.Constants.AuthorizationURL,InstaClient.Constants.ClientID,InstaClient.Constants.RedirectURI)
        
        let authorizationURL = NSURL(string: modifiedURLString)
        
        let request = NSURLRequest(URL: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("InstaAuthViewController") as! InstaAuthViewController
        webAuthViewController.urlRequest = request
        
        webAuthViewController.completionHandler = completionHandler
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        })
    }
    
    func webLogout(hostViewController: UIViewController, completionHandler: (success: Bool,accessToken:String?, errorString: String?) -> Void) {
        

    }
    
    func logout(hostViewController: UIViewController){
        
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().accessTokenfilePath) != nil){
            print(CoreDataStackManager.sharedInstance().deleteFile(InstaClient.sharedInstance().accessTokenfilePath))
            InstaClient.sharedInstance().accessToken = nil
        }

        UIView.animateWithDuration(0.75, animations: {
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromLeft, forView: hostViewController.navigationController!.view, cache: false)
        })
        
        hostViewController.navigationController?.popViewControllerAnimated(false)

    }

    
    
    func getTags(var string:String,let context:NSManagedObjectContext,completionHandler: (result: [Tag]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        
        //method could have a tag with an accent like "Atatürk". We need to escape such characters.
        string = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let parameters = ["q":string]
        let mutableMethod : String = Methods.TagsSearch
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey("data") as? [[String : AnyObject]] {

                    context.performBlockAndWait(){

                    let tags = Tag.tagsFromResults(results,context: context)
                    completionHandler(result: tags, error: nil)
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getTags parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getTags"]))
                }
            }
            
        }
    }

    
    func getLocations(latitude:Double,longitude:Double,distance:Int,completionHandler: (result: [InstaLocation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = ["lat":latitude,"lng":longitude,"distance":distance]
        let mutableMethod : String = Methods.Locations
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters as! [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey("data") as? [[String : AnyObject]] {
                    CoreDataStackManager.sharedInstance().managedObjectContext!.performBlockAndWait(){

                    let locations = InstaLocation.locationsFromResults(results,context:self.sharedContext)
                    completionHandler(result: locations, error: nil)
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getLocations"]))
                }
            }
        }
    }
    
    func getMediaFromTag(var tag:String,completionHandler: (result: [InstaMedia]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String : AnyObject]()
        var mutableMethod : String = Methods.MediaTag
        /* 2/3. Build the URL and configure the request */
        //method could have a tag with an accent like "Atatürk". We need to escape such characters.
        tag = tag.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!

        mutableMethod = InstaClient.subtituteKeyInMethod(mutableMethod, key: "tag-name", value: tag)!
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey("data") as? [[String : AnyObject]] {
                    CoreDataStackManager.sharedInstance().managedObjectContext!.performBlockAndWait(){

                    let media = InstaMedia.imagesFromResults(results,context:self.sharedContext)
                    completionHandler(result: media, error: nil)
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getMediaFromTag parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMediaFromTag"]))
                }
            }
        }
    }

    
    func getMediaFromLocation(location:InstaLocation,completionHandler: (result: [InstaMedia]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String : AnyObject]()
        var mutableMethod : String = Methods.MediaLocation
        mutableMethod = InstaClient.subtituteKeyInMethod(mutableMethod, key: InstaClient.LocationKeys.LocationID, value: String(location.id))!
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey("data") as? [[String : AnyObject]] {
                    CoreDataStackManager.sharedInstance().managedObjectContext!.performBlockAndWait(){

                    let media = InstaMedia.imagesFromResults(results,context:self.sharedContext)
                    completionHandler(result: media, error: nil)
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getMediaFromLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMediaFromLocation"]))
                }
            }
            
        }
    }
    
    //The default time span is set to 5 days.
    func getMedia(latitude:Double,longitude:Double,distance:Int,completionHandler: (result: [InstaMedia]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = ["lat":latitude,"lng":longitude,"distance":distance]
        let mutableMethod : String = Methods.MediaSearch

        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters as! [String : AnyObject] ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey("data") as? [[String : AnyObject]] {
                    CoreDataStackManager.sharedInstance().managedObjectContext!.performBlockAndWait(){

                    let media = InstaMedia.imagesFromResults(results,context:self.sharedContext)
                    completionHandler(result: media, error: nil)
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getMedia parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMedia"]))
                }
            }
            
        }
    }
    

    
    //http://stackoverflow.com/questions/15945497/merge-two-uiimageview-into-single-a-single-uiimageview-in-ios
    //It blends 2 images. When I need to display a delete icon in front of an image I use this function
    func imageWithView(imageView:UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, CGFloat(1.0))
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    



}

