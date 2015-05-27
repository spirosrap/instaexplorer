//
//  MediaTableViewCell.swift
//  instaexplorer
//
//  Created by Spiros Raptis on 13/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {

 @IBOutlet var mainIm: UIImageView!
    //{
//        get{
//            if(mainIm != nil){
//                self.mainIm.layer.cornerRadius = self.mainIm.frame.size.width / 10
//                self.mainIm.clipsToBounds = true
//            }
//            return self.mainIm
//        }
//        set{
//            
//        }
//    }
    @IBOutlet var profileIm: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
