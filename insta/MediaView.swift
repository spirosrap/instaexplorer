//
//  mediaView.swift
//  instaplaces
//
//  Created by Spiros Raptis on 13/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

@IBDesignable class MediaView: UIView {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var view: UIView!
    @IBOutlet var clickableText: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var LocationTextView: UITextView!

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
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        //        // Make the view stretch with containing view
                view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MediaView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
}
}
