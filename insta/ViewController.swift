//
//  ViewController.swift
//  insta
//
//  Created by Spiros Raptis on 03/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().accessTokenfilePath) != nil){
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")! as! UITabBarController
            
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

        
        InstaClient.sharedInstance().loginWithToken(self){
            success,errorString in
            
            if success{
                var appDelegateTemp = UIApplication.sharedApplication().delegate
                let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")! as! UITabBarController
                
                appDelegateTemp!.window!!.rootViewController = detailController
                                
                
            }else{
                println(errorString)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }

}

