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
        InstaClient.sharedInstance().loginWithToken(self){
            success,errorString in
            if success{
                println(success)
                InstaClient.sharedInstance().getLocations( 40.632178, longitude: 22.940604, distance: 1000, completionHandler: { (result, error) -> Void in
                    println(result)
                    for ra in result!{
                        println(ra.id)
                    }
                })
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

