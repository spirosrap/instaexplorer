//
//  LoginViewController.swift
//  instaexplorer
//  The login controller to handle the request for login to instagram to use the app
//  Created by Spiros Raptis on 03/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().accessTokenfilePath) != nil){
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            
            self.navigationController!.presentViewController(detailController, animated: true) {
                self.navigationController?.popViewControllerAnimated(true)
                return ()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func login(sender: AnyObject) {
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()

        if(networkStatus.rawValue == NotReachable.rawValue){
            displayMessageBox("No Network Connection")
        }else{
            InstaClient.sharedInstance().loginWithToken(self){
                success,errorString in
                if success{
                    let appDelegateTemp = UIApplication.sharedApplication().delegate
                    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    
                    appDelegateTemp!.window!!.rootViewController = detailController //Set the tabbar as the root controller for the next time the user will login to avoid a unnecessary segway from login controller when already logged in
                    

                }else{
                    print(errorString)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    //A simple Alert view with an OK Button
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

