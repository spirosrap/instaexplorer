//
//  PhotoAlbumViewController.swift
//  instaexplorer
//  Created by Spiros Raptis on 19/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UITableViewDelegate,NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!

//    @IBOutlet var indicator: UIActivityIndicatorView! //The activity Indicator for the informationBox(not an alert view)
//    @IBOutlet var imageInfoView: UIImageView!
//    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet weak var selectViewSegmentedControl: ADVSegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    var prefetchedPhotos: [InstaMedia]!//We put the Photo Objects in a variable to use in NSFetchedResultsControllerDelegate methods
    var newCollectionButton:UIBarButtonItem!
    var location:Location!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //We invoke a performfetch for already fetched sets of image urls(the first stage) to be able to use it's delegate functionality
//        fetchedResultsController.performFetch(nil)
//        fetchedResultsController.delegate = self
        
//        imageInfoView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.70)
//        imageInfoView.hidden = true
//        infoLabel.hidden = true

        tableView.hidden = true
        tableView.delegate = self
        
        selectViewSegmentedControl.items = ["Collection", "Table"]
        selectViewSegmentedControl.font = UIFont(name: "Avenir-Black", size: 12)
        selectViewSegmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        selectViewSegmentedControl.selectedIndex = 0
        selectViewSegmentedControl.addTarget(self, action: "switchViews:", forControlEvents: .ValueChanged)


    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let kCellsPerRow:CGFloat = 3

        
        let flowLayout:UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidthForCells:CGFloat = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
        let cellWidth:CGFloat = availableWidthForCells / kCellsPerRow;
        flowLayout.itemSize = CGSizeMake(flowLayout.itemSize.height, cellWidth);
        flowLayout.itemSize.width = flowLayout.itemSize.height

        return flowLayout.itemSize
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.navigationBarHidden = true
//        self.navigationController?.toolbarHidden = true
//        for p in prefetchedPhotos{
//            CoreDataStackManager.sharedInstance().deleteObject(p)
//        }
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = true
        
     }

    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

            switch type {
            case .Delete:
                self.collectionView.deleteItemsAtIndexPaths([indexPath!])
            case .Update:
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                let photo = controller.objectAtIndexPath(indexPath!) as! InstaMedia
                cell.photo.image = photo.thumbnail
            default:
                return
            }

    }
    
    //MARK: Collection View Related
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [InstaMedia]
//        for pf in (prefetchedPhotos!){
//            print(pf.location)
//        }
        return prefetchedPhotos!.count
    }

    
    //Display the Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        //If the photo image(imagepaths and titles are saved in Core Data) is saved using NSKeyedArchiver / NSKeyedUnarchiver we display it right away else we download it using its imagepath
        let changedPath = prefetchedPhotos![indexPath.row].thumbnailPath!.stringByReplacingOccurrencesOfString("/", withString: "")//Because instagram returns the same lastpathcomponent for images and thumbnails I introduced this hack(replaced all "/" characters) to enable different paths for the same lastpathcomponents.

        
        
        if let photo = NSKeyedUnarchiver.unarchiveObjectWithFile(InstaClient.sharedInstance().imagePath(changedPath)) as? UIImage {
            cell.indicator.stopAnimating()
            cell.photo.image = photo

        }else{
            cell.indicator.startAnimating()
            cell.photo.image = UIImage(named: "PlaceHolder") //Default placeholder
            
            InstaClient.sharedInstance().downloadImageAndSetCell(prefetchedPhotos![indexPath.row].thumbnailPath!,photo: cell.photo,completionHandler: { (success, errorString) in
                if success {                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.indicator.stopAnimating()
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.indicator.stopAnimating()
                    })
                }
            })
        }
        
        
        return cell
    }
    
    //It is used for deleting the image from the collection view and the underlying core data context
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath){
        let photo = prefetchedPhotos[indexPath.row]
        _ = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        let paController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController") as! ImageDetailViewController
        
        if let t = photo.text{
            paController.userComment = t
        }
        paController.mediaID = photo.mediaID!
        paController.instaMedia = photo
        _ = paController.view//Important. fatal error if not present. We need to first allocate the view.(Whole view be present in memory)



        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController!.pushViewController(paController, animated: true)
        }


        
//        CoreDataStackManager.sharedInstance().deleteObject(photo)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
            return CGFloat(4.0)
    }
    
    //Distance between cells in a row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(4.0)
    }
    
    //sets the border of the collection cell
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 10.0)
    }

    
    
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
//        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [InstaMedia]

        return prefetchedPhotos!.count
    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tablecell", forIndexPath: indexPath) as! MediaTableViewCell
        
        
        


        
        var frame = cell.profileIm.frame
        frame.size.height = cell.profileIm.frame.size.width
        frame.size.width  = cell.profileIm.frame.size.width
        cell.profileIm.frame = frame
        cell.profileIm.layer.cornerRadius = cell.profileIm.frame.size.width / 2.0
        cell.profileIm.clipsToBounds = true


        InstaClient.sharedInstance().setImage(prefetchedPhotos![indexPath.row].imagePath!, imageView: cell.mainIm)
        InstaClient.sharedInstance().setImage(prefetchedPhotos![indexPath.row].profileImagePath!, imageView: cell.profileIm)
        cell.usernameLabel.text = "@" + prefetchedPhotos![indexPath.row].username!
        if let il = prefetchedPhotos![indexPath.row].instaLocation{
            cell.locationLabel.text = il.name
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let photo = prefetchedPhotos[indexPath.row]
        let paController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController") as! ImageDetailViewController
        
        if let t = photo.text{
            paController.userComment = t
            print("comment1: \(t)")
        }
        paController.mediaID = photo.mediaID!
        paController.instaMedia = photo
        _ = paController.view//Important. fatal error if not present. We need to first allocate the view.(Whole view be present in memory)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController!.pushViewController(paController, animated: true)
        }

        
    }
    
    //MARK: Other: alert view and a custom made information Box
    
    //A simple Alert view with an OK Button
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //Custom Made information Box using alpha value to create a black transparent background.
    func informationBox(msg:String?,let animate:Bool){
        if let _ = msg{
//            if(animate){
//                indicator.startAnimating()
//            }
//            imageInfoView.hidden = false
//            infoLabel.hidden = false
//            infoLabel.text = msg
        }else{
//            imageInfoView.hidden = true
//            infoLabel.hidden = true
//            indicator.stopAnimating() //It doesn't hurt to stop animation in case it didn't start before
        }
    }
    
    @IBAction func switchViews(sender: ADVSegmentedControl) {
        switch (sender.selectedIndex) {
        case 0:
            collectionView.hidden = false
            tableView.hidden = true
            self.collectionView.reloadData()
            
        case 1:
            collectionView.hidden = true
            tableView.hidden = false
            self.tableView.reloadData()
        default:
            break;
        }
        
    }
}

