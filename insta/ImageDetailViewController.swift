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
    
    @IBOutlet weak var bottomView: UIView!
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
            
            attributedString  = NSMutableAttributedString(string: userComment, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14)!])
            
            for t in tags(userComment){
                var tagattributedString:NSAttributedString = NSAttributedString(string: t, attributes: [t:true,NSForegroundColorAttributeName:UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00),NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14)!])
                var range = NSString(string: attributedString.string).rangeOfString(t)
                attributedString.replaceCharactersInRange(range, withAttributedString: tagattributedString)
            }
            
            //Bug that prevents to change the font (but not color) of attributed text in xcode 6: http://openradar.appspot.com/radar?id=5117089870249984 forces me to create a text view programmatically on top of the storyboard one.

            var ct = UITextView(frame: self.view.frame)
            ct.attributedText = attributedString
            self.clickableText.addSubview(ct)
            
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
//            UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00) //Location
//            UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00) //Username
//            UIFont boldSystemFontOfSize:fontSize

            
            
            var usernameAttr  = NSMutableAttributedString(string: instaMedia.username!, attributes: [NSForegroundColorAttributeName:UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00), NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 17)!])
            var range = NSString(string: instaMedia.username!).rangeOfString(instaMedia.username!)
            usernameAttr.replaceCharactersInRange(range, withAttributedString: usernameAttr)
            

            
            profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 10
            profileImageView.clipsToBounds = true
            
            var utv = UITextView(frame: usernameTextView.alignmentRectForFrame(usernameTextView.frame))
            utv.attributedText = usernameAttr

            
            usernameTextView.addSubview(utv)

            
            if let locationName = instaMedia.instaLocation?.name {
                var locationAttr  = NSMutableAttributedString(string: locationName, attributes: [NSForegroundColorAttributeName:UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00), NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 17)!])
                var range = NSString(string: locationName).rangeOfString(locationName)
                locationAttr.replaceCharactersInRange(range, withAttributedString: locationAttr)

                
                var ltv = UITextView(frame: usernameTextView.alignmentRectForFrame(LocationTextView.frame))
                ltv.attributedText = locationAttr
                LocationTextView.attributedText = locationAttr
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
