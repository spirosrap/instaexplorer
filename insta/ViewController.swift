//
//  ViewController.swift
//  insta
//
//  Created by Spiros Raptis on 03/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import OAuthSwift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loginWithToken(self){
//            success,errorString in
//            if success{
//                println(success)
//            }else{
//                println(errorString)
//            }
//        }
        
        let oauthswift = OAuth2Swift(
            consumerKey:    InstaClient.Constants.ClientID,
            consumerSecret: InstaClient.Constants.ClientSecret,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        
        let state: String = generateStateWithLength(1) as String
        let webAuthViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InstaAuthViewController") as! InstaAuthViewController
        oauthswift.webViewController = webAuthViewController

        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(oauthswift.webViewController!, animated: false)
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        })
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "instaplaces://auth/instagram")!, scope: "likes+comments", state:"INSTAGRAM", success: {
            credential, response in
            self.showAlertView("Instagram", message: "oauth_token:\(credential.oauth_token)")
            let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=\(credential.oauth_token)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                    println(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    println(error)
            })
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
        

//        
//        let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=1092939.bd0da3c.2b6f7ed738b04f509d60d6b2865f7398"
//        let parameters :Dictionary = Dictionary<String, AnyObject>()
//        oauthswift.client.get(url, parameters: parameters,
//            success: {
//                data, response in
//                let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
//                println(jsonDict)
//            }, failure: {(error:NSError!) -> Void in
//                println(error)
//        })
//
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    /* This function opens a TMDBAuthViewController to handle Step 2a of the auth flow */
//    func loginWithToken(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
//        
//        let authorizationURL = NSURL(string: "\(InstaClient.Constants.AuthorizationURL)?client_id=\(InstaClient.Constants.ClientID)&redirect_uri=\(InstaClient.Constants.RedirectURI)&response_type=token")
//        
//        let request = NSURLRequest(URL: authorizationURL!)
//        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("InstaAuthViewController") as! InstaAuthViewController
//        webAuthViewController.urlRequest = request
//
//        webAuthViewController.completionHandler = completionHandler
//        
//        let webAuthNavigationController = UINavigationController()
//        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
//        })
//    }


    
    func showAlertView(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

}

