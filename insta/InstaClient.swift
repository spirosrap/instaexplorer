//
//  InstaClient.swift
//  instaexplorer
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class InstaClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
//    var config = InstaConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    var accessToken: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters["access_token"] = self.accessToken!
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + InstaClient.escapedParameters(mutableParameters)
        print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = InstaClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                InstaClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
//        method = method.stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]\
        
        let urlString = Constants.BaseURLSecure + method + InstaClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch  {
            request.HTTPBody = nil
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = InstaClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                InstaClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[InstaClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            _ = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> InstaClient {
        
        struct Singleton {
            static var sharedInstance = InstaClient()
        }
        
        return Singleton.sharedInstance
    }
    
    //MARK:Saving Related
    //It returns the actual path in the iOS readable format
    func imagePath(let selectedFilename:String) ->String{
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent(selectedFilename).path!
    }
    
    
    //It set asynchronously an imageview
    func setImage(let imagePath:String,let imageView:UIImageView){
        
        let changedPath = imagePath.stringByReplacingOccurrencesOfString("/", withString: "")//Because instagram returns the same lastpathcomponent for images and thumbnails I introduced this hack(replaced all "/" characters) to enable different paths for the same lastpathcomponents.
        if let p = NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().imagePath(changedPath)) as? UIImage {
            //            cell.indicator.stopAnimating()
            imageView.image = p
        }else{
            imageView.image = UIImage(named: "PlaceHolder") //Default placeholder
            
            InstaClient.sharedInstance().downloadImageAndSetCell(imagePath,photo: imageView,completionHandler: { (success, errorString) in
                if success {
                }else{
                }
            })
        }
    }
    


    //It downloads the images from the already saved image paths to be in turn saved too in the CoreData
    func downloadImageAndSetCell(let imagePath:String,let photo:UIImageView,completionHandler: (success: Bool, errorString: String?) -> Void){
        let changedPath = imagePath.stringByReplacingOccurrencesOfString("/", withString: "") //Because instagram returns the same lastpathcomponent for images and thumbnails I introduced this hack(replaced all "/" characters) to enable different paths for the same lastpathcomponents.
        if let p = NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().imagePath(changedPath)) as? UIImage {
            photo.image = p
            completionHandler(success: true, errorString: nil)
        }else{
            let imgURL = NSURL(string: imagePath)
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            _ = NSOperationQueue.mainQueue()
            photo.image = UIImage(named: "PlaceHolder")

            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    let changedPath = imagePath.stringByReplacingOccurrencesOfString("/", withString: "")//Because instagram returns the same lastpathcomponent for images and thumbnails I introduced this hack(replaced all "/" characters) to enable different paths for the same lastpathcomponents.
                    
                    if let im = image{
                        NSKeyedArchiver.archiveRootObject(im,toFile: InstaClient.sharedInstance().imagePath(changedPath))
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        photo.image = image
                    }
                    completionHandler(success: true, errorString: nil)
                }
                else {
                    completionHandler(success: false, errorString: "Could not download image \(imagePath)")
                }
            })
            
            task.resume()
        }

    }

    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }

}