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
        var  count:CGFloat    = CGFloat(self.viewControllers!.count)
        var tabBarSize:CGSize = self.tabBar.frame.size
        var padding:CGFloat = CGFloat(0);
        var buttonSize = CGSizeMake( tabBarSize.width / count, tabBarSize.height );
        UIGraphicsBeginImageContext( buttonSize );
        var c:CGContextRef = UIGraphicsGetCurrentContext();
        UIColor(white: 0.9, alpha: 0.1).setFill()
        var roundedRect:UIBezierPath = UIBezierPath(roundedRect: CGRectMake(padding,padding * 2, buttonSize.width - (padding * 2),buttonSize.height - ( padding * 2 ) ), cornerRadius: 4.0)
        roundedRect.fillWithBlendMode(kCGBlendModeNormal, alpha: 1.0)
        
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        return image;

    }

}
