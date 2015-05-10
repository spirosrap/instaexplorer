//
//  ImageDetailViewController.swift
//  instaplaces
//
//  Created by Spiros Raptis on 09/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var clickableText: UITextView!
    var userComment:String!
    
    var attributedString = NSMutableAttributedString(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        println("comment2: \(userComment)")
        if let userComment = userComment{
            var paragraph  = NSMutableParagraphStyle()
            paragraph.alignment = .Justified
            paragraph.lineSpacing = 3
            attributedString  = NSMutableAttributedString(string: userComment, attributes: [NSForegroundColorAttributeName:UIColor.blackColor()])

            for t in tags(userComment){
                var tagattributedString:NSAttributedString = NSAttributedString(string: t, attributes: [t:true,NSForegroundColorAttributeName:UIColor.blueColor()])
                var range = NSString(string: attributedString.string).rangeOfString(t)
                attributedString.replaceCharactersInRange(range, withAttributedString: tagattributedString)
            }
            
            self.clickableText.attributedText = attributedString
            
            var  tap = UITapGestureRecognizer(target: self, action: "clickableTouched:")
            self.clickableText.addGestureRecognizer(tap)
            
        }

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("Clickable : \(userComment)")
        
    }
    
    func clickableTouched(recognizer:UITapGestureRecognizer) -> Void{
        var textView = recognizer.view as! UITextView
        var layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        var characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        

        if (characterIndex < textView.textStorage.length){
            for t in tags(userComment){
                
                var range = NSString(string: attributedString.string).rangeOfString(t)

                var value:AnyObject? = textView.textStorage.attribute(t, atIndex: characterIndex, effectiveRange: &range)
                if(value != nil){
                    println("clicked: \(t)")
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tags(var searchString:String) -> [String]{
        var retValue = [String]()
//        http://stackoverflow.com/questions/7534665/the-best-regex-to-parse-twitter-hashtags-and-users
        while(true){ // for username:  "((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})"
            if let tag = searchString.rangeOfString("((?:#){1}[\\w\\d]{1,140})",options: .RegularExpressionSearch){
                retValue.append(searchString.substringWithRange(tag))
                searchString = searchString.substringFromIndex(tag.endIndex)
            }else{
                break
            }
        }
        return retValue
    }
    
    
}
