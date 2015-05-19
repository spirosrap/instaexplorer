//
//  PhotoAlbumViewController.swift
//
//  Created by Spiros Raptis on 19/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FavoritesAlbumViewController: UIViewController,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!

//    @IBOutlet var indicator: UIActivityIndicatorView! //The activity Indicator for the informationBox(not an alert view)
//    @IBOutlet var imageInfoView: UIImageView!
//    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet weak var selectViewSegmentedControl: ADVSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var editButton = UIBarButtonItem()

    var prefetchedPhotos: [InstaMedia]!//We put the Photo Objects in a variable to use in NSFetchedResultsControllerDelegate methods
    var newCollectionButton:UIBarButtonItem!
    var location:Location!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = false
        
        //We invoke a performfetch for already fetched sets of image urls(the first stage) to be able to use it's delegate functionality
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
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

        editButton = UIBarButtonItem(title: "Edit", style: .Done, target: self, action: "edit")
        self.navigationItem.leftBarButtonItem = editButton

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var kCellsPerRow:CGFloat = 3

        
        var flowLayout:UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var availableWidthForCells:CGFloat = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
        var cellWidth:CGFloat = availableWidthForCells / kCellsPerRow;
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
        
        self.tableView.editing = false
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = true
        self.tableView.reloadData()
        self.collectionView.reloadData()

    }

    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //Add the lazy fetchedResultsController property. Photos are already fetched(from flickr) and saved in Core data before this screen, but we fetch them again to use the NSFetchedResultsControllerDelegate methods
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "InstaMedia")
        var l:NSNumber = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "favorite == %@", l);

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
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
        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [InstaMedia]
//        for pf in (prefetchedPhotos!){
//            print(pf.location)
//        }
        return prefetchedPhotos!.count
    }

    
    //Display the Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        //If the photo image(imagepaths and titles are saved in Core Data) is saved using NSKeyedArchiver / NSKeyedUnarchiver we display it right away else we download it using its imagepath
        var changedPath = prefetchedPhotos![indexPath.row].thumbnailPath!.stringByReplacingOccurrencesOfString("/", withString: "")

        
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        let paController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController")! as! ImageDetailViewController
        
        if let t = photo.text{
            paController.userComment = t
            println("comment1: \(t)")
        }
        paController.mediaID = photo.mediaID!
        paController.instaMedia = photo
        var a = paController.view//Important. fatal error if not present. We need to first allocate the view.(Whole view be present in memory)



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

    
//    //MARK: New Collection Button
//    //Generate a new collection of (12) images
//    func newCollection() -> Bool { //I added a return value to exit when there is no connection
//
//        var networkReachability = Reachability.reachabilityForInternetConnection()
//        var networkStatus = networkReachability.currentReachabilityStatus()
//        
//        if(networkStatus.value == NotReachable.value){// Before searching fοr an additonal Photos in Flickr check if there is an available internet connection
//            displayMessageBox("No Network Connection")
//            return false
//        }
//        
//        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)//the appdelegate keeps a "Statistics" instance.
//        informationBox("Connecting to Flickr",animate:true)
//        newCollectionButton.enabled = false
//        Flickr.sharedInstance().populateLocationPhotos(location) { (success,photosArray, errorString) in
//            if success {
//                println("finished retrieving imagepaths")
//
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    //Deleting the previous set of photos. It's inside dispatch_async because
//                    //We avoid having a blank screen(deleted photos) while waiting a reply from flickr
//                    for p in self.location.photos!{
//                        CoreDataStackManager.sharedInstance().deleteObject(p)
//                    }
//                    
//                    if let pd = photosArray{//We create the Photo instances from the photosArray and save them.
//                        for p in pd{
//                            let photo = Photo(dictionary: ["title":p[0],"imagePath":p[1]], context: self.sharedContext)
//                            photo.location = self.location
//                            applicationDelegate.stats.photosDisplayed += 1 //Save the number of displayed images for statistics.
//                            CoreDataStackManager.sharedInstance().saveContext()
//                        }
//                    }
//                    self.informationBox(nil,animate:false)
//                    self.newCollectionButton.enabled = true
//                    self.collectionView.reloadData()
//                })
//            } else {
//                self.informationBox(nil,animate:false)
//                self.displayMessageBox(errorString!) //Its appropriate at this point to display an Alert
//                self.newCollectionButton.enabled = true
//                println(errorString!)
//            }
//        }
//        return true
//    }
    
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [InstaMedia]

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
        let paController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController")! as! ImageDetailViewController
        
        if let t = photo.text{
            paController.userComment = t
            println("comment1: \(t)")
        }
        paController.mediaID = photo.mediaID!
        paController.instaMedia = photo
        var a = paController.view//Important. fatal error if not present. We need to first allocate the view.(Whole view be present in memory)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController!.pushViewController(paController, animated: true)
        }

        
    }
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    //For deleting the Meme
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        prefetchedPhotos![indexPath.row].favorite = 0

        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func edit(){
        if editButton.title! == "Edit"{
            editButton.title = "Done"
        }else{
            editButton.title = "Edit"
        }
        self.tableView.editing = !self.tableView.editing
    }

    //MARK: Other: alert view and a custom made information Box
    
    //A simple Alert view with an OK Button
    func displayMessageBox(message:String){
        var alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //Custom Made information Box using alpha value to create a black transparent background.
    func informationBox(var msg:String?,let animate:Bool){
        if let m = msg{
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

