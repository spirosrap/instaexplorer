//
//  ImageDetailViewController.swift
//  instaplaces
//
//  Created by Spiros Raptis on 09/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import CoreData
class ImageDetailViewController: UIViewController,UIScrollViewDelegate {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var clickableText: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var LocationTextView: UITextView!
    @IBOutlet var star: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    var mediaID:String!
    var instaMedia:InstaMedia!
    var userComment:String!
    var attributedString = NSMutableAttributedString(string: "")
//    var ct:UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.performFetch(nil)
        let sectionInfo = fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo

        scrollView.delegate = self
//        scrollView.contentSize = CGSizeMake(400, self.view.frame.height);
//        scrollView.contentSize = self.view.frame.size
        
        if let userComment = userComment{
            
            attributedString  = atex( "@" + instaMedia.username! + " " + userComment,fontname: "HelveticaNeue",textColor:UIColor.blackColor(),linkColor: UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00),size: 14)
            
            //Bug that prevents to change the font (but not color) of attributed text in xcode 6: http://openradar.appspot.com/radar?id=5117089870249984 forces me to create a text view programmatically on top of the storyboard one.
            self.clickableText.attributedText = attributedString
            var  tap = UITapGestureRecognizer(target: self, action: "clickableTouched:")
            clickableText.addGestureRecognizer(tap)
            clickableText.editable = false
            clickableText.selectable = false
            
//            ct = UITextView(frame: self.clickableText.frame)
//            ct.attributedText = attributedString
//
//            self.clickableText.addSubview(ct)
//            
//            var  tap = UITapGestureRecognizer(target: self, action: "clickableTouched:")
//            ct.addGestureRecognizer(tap)
//            ct.editable = false
//            ct.selectable = false
        }
        
        
        
        
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
            usernameTextView.editable = false
            usernameTextView.selectable = false
            
            
            if let locationName = instaMedia.instaLocation?.name {
                var locationAttr  = NSMutableAttributedString(string: locationName, attributes: [NSForegroundColorAttributeName:UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00), NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 17)!])
                var range = NSString(string: locationName).rangeOfString(locationName)
                locationAttr.replaceCharactersInRange(range, withAttributedString: locationAttr)
                
                
                var ltv = UITextView(frame: usernameTextView.alignmentRectForFrame(LocationTextView.frame))
                ltv.attributedText = locationAttr
                LocationTextView.attributedText = locationAttr
            }
            
            InstaClient.sharedInstance().setImage(instaMedia.imagePath!,imageView:imageView)
            InstaClient.sharedInstance().setImage(instaMedia.profileImagePath!,imageView: profileImageView)
            
            if (instaMedia.favorite! == 0){
                star.setImage(UIImage(named: "star_disabled"), forState: .Normal)
            }else{
                star.setImage(UIImage(named: "star_enabled"), forState: .Normal)
            }
            
        }

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        
        
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {

//        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
    
    func atex(let string:String,let fontname:String,let textColor:UIColor,let linkColor:UIColor,let size:CGFloat) -> NSMutableAttributedString {
        var attributedString  = NSMutableAttributedString(string: string, attributes: [NSForegroundColorAttributeName:textColor, NSFontAttributeName:UIFont(name: fontname, size: size)!])
        
        for t in tags(string){
            var tagattributedString:NSAttributedString = NSAttributedString(string: t, attributes: [t:true,NSForegroundColorAttributeName:linkColor,NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14)!])
            var range = NSString(string: attributedString.string).rangeOfString(t)
            attributedString.replaceCharactersInRange(range, withAttributedString: tagattributedString)
        }
        
        return attributedString
    }

    
    func clickableTouched(recognizer:UITapGestureRecognizer) -> Void{
        println(recognizer.state.rawValue)
        
//        if(recognizer.state == .Changed){
//            attributedString  = atex(userComment,fontname: "HelveticaNeue",textColor:UIColor.blackColor(),linkColor: UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00),size: 14)
//            ct.removeFromSuperview()
//            ct = UITextView(frame: self.view.frame)
//            ct.attributedText = attributedString
//            self.clickableText.addSubview(ct)
//        }else if (recognizer.state == .Ended){
//            attributedString  = atex(userComment,fontname: "HelveticaNeue",textColor:UIColor.blackColor(),linkColor: UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00),size: 14)
//            ct.removeFromSuperview()
//            ct = UITextView(frame: self.view.frame)
//            ct.attributedText = attributedString
//            self.clickableText.addSubview(ct)
//        }

        var textView = recognizer.view as! UITextView
        var layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        var characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        

        if (characterIndex < textView.textStorage.length){
            for t in tags(attributedString.string){
                
                var range = NSString(string: attributedString.string).rangeOfString(t)

                var value:AnyObject? = textView.textStorage.attribute(t, atIndex: characterIndex, effectiveRange: &range)
                if(value != nil){
                    
                    println("clicked: \(t)")
                    if t.rangeOfString("#") != nil {
                        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("displayTaggedMedia")! as! PhotoAlbumViewController
                        var tag = t.substringWithRange(Range<String.Index>(start: t.rangeOfString("#")!.endIndex, end: t.endIndex))
                        InstaClient.sharedInstance().getMediaFromTag(tag, completionHandler: { (result, error) -> Void in
                            if error == nil{
                                dispatch_async(dispatch_get_main_queue(), {

                                    detailController.prefetchedPhotos = result! as [InstaMedia]
                                    detailController.navigationController?.navigationBar.hidden = false
                                    self.navigationController!.pushViewController(detailController, animated: true)
                                })
                            }
                        })
                    }
                }
            }
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
            if let tag = searchforusernames.rangeOfString("((?:^|\\s)(?:@){1}[0-9a-zA-Z_.]{1,50})",options: .RegularExpressionSearch){
                retValue.append(searchforusernames.substringWithRange(tag))
                searchforusernames = searchforusernames.substringFromIndex(tag.endIndex)
            }else{
                break
            }
        }

        println(retValue)
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
    
    @IBAction func favoriteClicked(sender: UIButton) {
        if instaMedia.favorite! == 0{
            instaMedia.favorite = 1
            CoreDataStackManager.sharedInstance().saveContext()
            star.setImage(UIImage(named: "star_enabled"), forState: .Normal)
        }else{
            instaMedia.favorite = 0
            CoreDataStackManager.sharedInstance().saveContext()
            star.setImage(UIImage(named: "star_disabled"), forState: .Normal)
            
        }
    }
    
    
}
