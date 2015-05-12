//
//  ImageDetailViewController.swift
//  instaplaces
//
//  Created by Spiros Raptis on 09/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import CoreData

class ImageDetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var clickableText: UITextView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameTextView: UITextView!
    
    @IBOutlet weak var LocationTextView: UITextView!
    
    var mediaID:String!
    
    var userComment:String!
    
    var attributedString = NSMutableAttributedString(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        


        if let userComment = userComment{
            var paragraph  = NSMutableParagraphStyle()
            paragraph.alignment = .Justified
            paragraph.lineSpacing = 3
            attributedString  = NSMutableAttributedString(string: userComment, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(),                NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 13)!])
            

            for t in tags(userComment){
                var tagattributedString:NSAttributedString = NSAttributedString(string: t, attributes: [t:true,NSForegroundColorAttributeName:UIColor.blueColor(),NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 13)!])
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
        
        fetchedResultsController.performFetch(nil)
        let sectionInfo = fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        var instaMedia:InstaMedia
        
        if  !sectionInfo.objects.isEmpty{
            instaMedia = sectionInfo.objects[0] as! InstaMedia
            println(instaMedia.text)
            
            profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 10
            
            profileImageView.clipsToBounds = true
            usernameTextView.text = "@" + instaMedia.username!

            
            if let locationName = instaMedia.instaLocation?.name {
                LocationTextView.text = locationName
            }
            setImage(instaMedia.imagePath!,imageView:imageView)
            setImage(instaMedia.profileImagePath!,imageView: profileImageView)
        
        }

    }
    
    func tags(var searchString:String) -> [String]{
        var retValue = [String]()
        var searchforusernames = searchString

//        http://stackoverflow.com/questions/7534665/the-best-regex-to-parse-twitter-hashtags-and-users
        while(true){ // for username:  "((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})"
            if let tag = searchString.rangeOfString("((?:#){1}[\\w\\d]{1,140})",options: .RegularExpressionSearch){
                retValue.append(searchString.substringWithRange(tag))
                searchString = searchString.substringFromIndex(tag.endIndex)
            }else{
                break
            }
        }
        while(true){ // for username:  "((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})"
            if let tag = searchforusernames.rangeOfString("((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,50})",options: .RegularExpressionSearch){
                retValue.append(searchforusernames.substringWithRange(tag))
                searchforusernames = searchforusernames.substringFromIndex(tag.endIndex)
            }else{
                break
            }
        }

        
        return retValue
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "InstaMedia")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "mediaID == %@", self.mediaID);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    func setImage(let imagePath:String,let imageView:UIImageView){
        
        var changedPath = imagePath.stringByReplacingOccurrencesOfString("/", withString: "")
        if let p = NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().imagePath(changedPath)) as? UIImage {
            //            cell.indicator.stopAnimating()
            imageView.image = p
        }else{
            //            cell.indicator.startAnimating()
            imageView.image = UIImage(named: "PlaceHolder") //Default placeholder
            
            InstaClient.sharedInstance().downloadImageAndSetCell(imagePath,photo: imageView,completionHandler: { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        //                        cell.indicator.stopAnimating()
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        //                        cell.indicator.stopAnimating()
                    })
                }
            })
        }

    }
}
