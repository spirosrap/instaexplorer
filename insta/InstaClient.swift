//
//  TMDBClient.swift
//  TheMovieManager
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
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = InstaClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                InstaClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
//    func taskForGETImage(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
//        
//        /* 1. Set the parameters */
//        // There are none...
//        
//        /* 2/3. Build the URL and configure the request */
//        let urlComponents = [size, filePath]
//        let baseURL = NSURL(string: config.baseImageURLString)!
//        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
//        let request = NSURLRequest(URL: url)
//        
//        /* 4. Make the request */
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            /* 5/6. Parse the data and use the data (happens in completion handler) */
//            if let error = downloadError {
//                let newError = TMDBClient.errorForData(data, response: response, error: downloadError)
//                completionHandler(imageData: nil, error: newError)
//            } else {
//                completionHandler(imageData: data, error: nil)
//            }
//        }
//        
//        /* 7. Start the request */
//        task.resume()
//        
//        return task
//    }

    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + InstaClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = InstaClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                InstaClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Use this unFavoriteButtonTouchUpInside as a reference if you need it 😄 */
    
//    func unFavoriteButtonTouchUpInside(sender: AnyObject) {
//        
//        /* TASK: Remove movie as favorite, then update favorite buttons */
//        
//        /* 1. Set the parameters */
//        let methodParameters = [
//            "api_key": appDelegate.apiKey,
//            "session_id": appDelegate.sessionID!
//        ]
//        
//        /* 2. Build the URL */
//        let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite" + appDelegate.escapedParameters(methodParameters)
//        let url = NSURL(string: urlString)!
//        
//        /* 3. Configure the request */
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.HTTPBody = "{\"media_type\": \"movie\",\"media_id\": \(self.movie!.id),\"favorite\":false}".dataUsingEncoding(NSUTF8StringEncoding)
//        
//        /* 4. Make the request */
//        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
//            
//            if let error = downloadError? {
//                println("Could not complete the request \(error)")
//            } else {
//                
//                /* 5. Parse the data */
//                var parsingError: NSError? = nil
//                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as NSDictionary
//                
//                /* 6. Use the data! */
//                if let status_code = parsedResult["status_code"] as? Int {
//                    if status_code == 13 {
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.unFavoriteButton.hidden = true
//                            self.favoriteButton.hidden = false
//                        }
//                    }
//                } else {
//                    println("Could not find status_code in \(parsedResult)")
//                }
//            }
//        }
//        
//        /* 7. Start the request */
//        task.resume()
//    }
    
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
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
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
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
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
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
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
    func imagePath(var selectedFilename:String) ->String{
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent(selectedFilename).path!
    }

    //It downloads the images from the already saved image paths to be in turn saved too in the CoreData
    func downloadImageAndSetCell(let imagePath:String,let cell:CollectionViewCell,completionHandler: (success: Bool, errorString: String?) -> Void){
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let mainQueue = NSOperationQueue.mainQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data)
                
                NSKeyedArchiver.archiveRootObject(image!,toFile: self.imagePath(imagePath.lastPathComponent))
                
                cell.photo.image = image
                completionHandler(success: true, errorString: nil)
            }
            else {
                completionHandler(success: false, errorString: "Could not download image \(imagePath)")
            }
        })
    }

    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }

}