//
//  ImageDetailViewController.swift
//  instaexplorer
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
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    var shareButton = UIBarButtonItem()
    var flexiblespace = UIBarButtonItem()
    var imageToShare = UIImage()
    var mediaID:String!
    var instaMedia:InstaMedia!
    var favoritedMedia:InstaMedia!
    var userComment:String!
    var attributedString = NSMutableAttributedString(string: "")
    
    @IBOutlet var imageIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        self.indicator.stopAnimating() //Sometimes indicator delays hiding, due to the asynchronous call to API.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        let sectionInfo = fetchedResultsController.sections![0] 
        
        scrollView.delegate = self
        
        if let userComment = userComment{
            
            attributedString  = atex( "@" + instaMedia.username! + " " + userComment,fontname: "HelveticaNeue",textColor:UIColor.blackColor(),linkColor: UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00),size: 14)
            
            //Bug that prevents to change the font (but not color) of attributed text in xcode 6: http://openradar.appspot.com/radar?id=5117089870249984 forces me to create a text view programmatically on top of the storyboard one.
            self.clickableText.attributedText = attributedString
            let  tap = UITapGestureRecognizer(target: self, action: "clickableTouched:")
            clickableText.addGestureRecognizer(tap)
            clickableText.editable = false
            clickableText.selectable = false
            
        }
        
        if  !sectionInfo.objects!.isEmpty{
            instaMedia = sectionInfo.objects![0] as! InstaMedia
            
            let usernameAttr  = NSMutableAttributedString(string: instaMedia.username!, attributes: [NSForegroundColorAttributeName:UIColor(red: 0.000, green: 0.176, blue: 0.467, alpha: 1.00), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 17)!])
            let range = NSString(string: instaMedia.username!).rangeOfString(instaMedia.username!)
            usernameAttr.replaceCharactersInRange(range, withAttributedString: usernameAttr)
            
            
            
            profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 10
            profileImageView.clipsToBounds = true
            
            
            usernameTextView.attributedText = usernameAttr
            usernameTextView.editable = false
            usernameTextView.selectable = false
            
            
            if let locationName = instaMedia.instaLocation?.name {
                let locationAttr  = NSMutableAttributedString(string: locationName, attributes: [NSForegroundColorAttributeName:UIColor(red: 0.051, green: 0.494, blue: 0.839, alpha: 1.00), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14)!])
                let range = NSString(string: locationName).rangeOfString(locationName)
                locationAttr.replaceCharactersInRange(range, withAttributedString: locationAttr)
                
                LocationTextView.attributedText = locationAttr
            }
            
            InstaClient.sharedInstance().setImage(instaMedia.profileImagePath!,imageView: profileImageView)
            shareButton.enabled = false
            imageIndicator.startAnimating()
            InstaClient.sharedInstance().downloadImageAndSetCell(instaMedia.imagePath!, photo: imageView, completionHandler: { (success, errorString) -> Void in
                if success{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.imageIndicator.stopAnimating()
                    }
                    self.imageToShare = self.imageView.image!
                    self.shareButton.enabled = true
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.imageIndicator.stopAnimating()
                    }
                    print(errorString)
                }
            })
            if (instaMedia.favorite! == 0){
                star.setImage(UIImage(named: "star_disabled"), forState: .Normal)
            }else{
                star.setImage(UIImage(named: "star_enabled"), forState: .Normal)
            }
            
        }
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        flexiblespace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItem = shareButton

    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {

//        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
    
    func atex(let string:String,let fontname:String,let textColor:UIColor,let linkColor:UIColor,let size:CGFloat) -> NSMutableAttributedString {
        let attributedString  = NSMutableAttributedString(string: string, attributes: [NSForegroundColorAttributeName:textColor, NSFontAttributeName:UIFont(name: fontname, size: size)!])
        
        for t in tags(string){
            let tagattributedString:NSAttributedString = NSAttributedString(string: t, attributes: [t:true,NSForegroundColorAttributeName:linkColor,NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14)!])
            let range = NSString(string: attributedString.string).rangeOfString(t)
            attributedString.replaceCharactersInRange(range, withAttributedString: tagattributedString)
        }
        
        return attributedString
    }

    
    func clickableTouched(recognizer:UITapGestureRecognizer) -> Void{
        

        let textView = recognizer.view as! UITextView
        let layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        

        if (characterIndex < textView.textStorage.length){
            for t in tags(attributedString.string){
                
                var range = NSString(string: attributedString.string).rangeOfString(t)

                let value:AnyObject? = textView.textStorage.attribute(t, atIndex: characterIndex, effectiveRange: &range)
                if(value != nil){
                    
                    if t.rangeOfString("#") != nil {
                        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("displayTaggedMedia") as! PhotoAlbumViewController
                        let tag = t.substringWithRange(Range<String.Index>(start: t.rangeOfString("#")!.endIndex, end: t.endIndex))

                        indicator.startAnimating()
                        InstaClient.sharedInstance().getMediaFromTag(tag, completionHandler: { (result, error) -> Void in
                            if error == nil{
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.indicator.stopAnimating()
                                    detailController.prefetchedPhotos = result! as [InstaMedia]
                                    detailController.navigationController?.navigationBar.hidden = false
                                    self.navigationController!.pushViewController(detailController, animated: true)
                                })
                            }else{
                                self.displayMessageBox("Could not get Images")
                                self.indicator.stopAnimating()
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
            star.setImage(UIImage(named: "star_disabled"), forState: .Normal)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func share(){
        _ = [UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeSaveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [instaMedia.link!,imageToShare], applicationActivities: nil)
        self.presentViewController(activity, animated: true, completion:nil)
    }

    //A simple Alert view with an OK Button
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
}
