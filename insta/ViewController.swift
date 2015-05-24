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
    
    @IBAction func login(sender: AnyObject) {
        InstaClient.sharedInstance().loginWithToken(self){
            success,errorString in
            
            if success{
                let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")! as! UITabBarController
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.presentViewController(detailController, animated: true) {
                        self.navigationController?.popViewControllerAnimated(true)
                        return ()
                    }

                }
                
                
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

