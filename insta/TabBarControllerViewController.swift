//
//  TabBarControllerViewController.swift
//  instaexplorer
//
//  Created by Spiros Raptis on 18/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class TabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.barTintColor = UIColor.blackColor()
        self.tabBar.selectionIndicatorImage = selectedImage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectedImage() -> UIImage{
        let  count:CGFloat    = CGFloat(self.viewControllers!.count)
        let tabBarSize:CGSize = self.tabBar.frame.size
        let padding:CGFloat = CGFloat(0);
        let buttonSize = CGSizeMake( tabBarSize.width / count, tabBarSize.height );
        UIGraphicsBeginImageContext( buttonSize );
        _ = UIGraphicsGetCurrentContext()!
        UIColor(white: 0.9, alpha: 0.1).setFill()
        let roundedRect:UIBezierPath = UIBezierPath(roundedRect: CGRectMake(padding,padding * 2, buttonSize.width - (padding * 2),buttonSize.height - ( padding * 2 ) ), cornerRadius: 4.0)
        roundedRect.fillWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        return image;

    }

}
