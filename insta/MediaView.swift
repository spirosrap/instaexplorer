//
//  mediaView.swift
//  instaplaces
//
//  Created by Spiros Raptis on 13/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class MediaView: UIView {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var view: UIView!
    @IBOutlet var clickableText: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var LocationTextView: UITextView!

    @IBOutlet weak var deleteLabel: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("MediaView", owner: self, options: nil)
 
        self.addSubview(self.view)
    }
    

}

