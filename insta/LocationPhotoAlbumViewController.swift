//
//  LocationPhotoAlbumViewController.swift
//  instaexplorer
//  Created by Spiros Raptis on 19/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationPhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UITableViewDelegate,NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var indicator: UIActivityIndicatorView! //The activity Indicator for the informationBox(not an alert view)
    @IBOutlet var map: MKMapView!
    @IBOutlet var imageInfoView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet weak var selectViewSegmentedControl: ADVSegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    var prefetchedPhotos: [InstaMedia]!//We put the Photo Objects in a variable to use in NSFetchedResultsControllerDelegate methods
    var newCollectionButton:UIBarButtonItem!
    var location:Location!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
        
        do {
            //We invoke a performfetch for already fetched sets of image urls(the first stage) to be able to use it's delegate functionality
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
        imageInfoView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.70)
        imageInfoView.hidden = true
        infoLabel.hidden = true
        
        tableView.hidden = true
        tableView.delegate = self
        
        selectViewSegmentedControl.items = ["Collection", "Table"]
        selectViewSegmentedControl.font = UIFont(name: "Avenir-Black", size: 12)
        selectViewSegmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        selectViewSegmentedControl.selectedIndex = 0
        selectViewSegmentedControl.addTarget(self, action: "switchViews:", forControlEvents: .ValueChanged)

        //"New Collection" Button and it's color
        newCollectionButton = UIBarButtonItem(title: "New Collection", style: .Plain, target: self, action: "newCollection")
        _ = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        newCollectionButton.tintColor =  UIColor(red: (255/255.0), green: (0/255.0), blue: (132/255.0), alpha: 1.0)
                self.navigationItem.rightBarButtonItem = newCollectionButton

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = true
        self.tableView.reloadData()
        self.collectionView.reloadData()
        
        setRegion() //Set the region on the top map based on the selected Location
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() //There was a bug with properly displaying the rounded profile images. It needed to hide and redisplay the view to display properly. With reloading data, it displays correctly
    }

    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //Add the lazy fetchedResultsController property. Photos are already fetched(from instagram) and saved in Core data before this screen, but we fetch them again to use the NSFetchedResultsControllerDelegate methods
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "InstaMedia")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location);
        
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
        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [InstaMedia]
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
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! InstaMedia
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
    
    //MARK: Set the region
    //Set the region of the small map on top of the collection view using the location.
    func setRegion(){
        let span = MKCoordinateSpanMake(2, 2)
        let coordinates = CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
        let region = MKCoordinateRegion(center: coordinates, span: span)
        let annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
        let tapPoint:CLLocationCoordinate2D = coordinates
        annotation.coordinate = tapPoint
        
        self.map.addAnnotation(annotation)
        self.map.setRegion(region, animated: true)
    }
    
        //MARK: New Collection Button
        //Generate a new collection
    func newCollection() -> Bool { //I added a return value to exit when there is no connection
    
            let networkReachability = Reachability.reachabilityForInternetConnection()
            let networkStatus = networkReachability.currentReachabilityStatus()
    
            if(networkStatus.rawValue == NotReachable.rawValue){// Before searching fοr  additional Photos in instagram check if there is an available internet connection
                displayMessageBox("No Network Connection")
                return false
            }
    
            _ = (UIApplication.sharedApplication().delegate as! AppDelegate)//the appdelegate keeps a "Statistics" instance.
            informationBox("Connecting to Instagram",animate:true)
            newCollectionButton.enabled = false
            indicator.startAnimating()
            InstaClient.sharedInstance().getMedia(Double(location.latitude), longitude: Double(location.longitude), distance: 100) { (result, error) -> Void in
                
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        //                                self.informationBox(nil,animate:false)
                        //instantiate the controller and pass the parameter location.

                        for p in self.prefetchedPhotos{
                            if(p.favorite != 1){
                               CoreDataStackManager.sharedInstance().deleteObject(p)
                            }
                        }

                        for il in result!{
                            il.location = self.location
                        }
                        
                        CoreDataStackManager.sharedInstance().saveContext()
                               dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                                self.collectionView.reloadData()
                                self.indicator.stopAnimating()
                                self.newCollectionButton.enabled = true

                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        //                                self.informationBox(nil,animate:false)
                        self.displayMessageBox("No available Photos Found")//Its appropriate at this point to display an Alert
                        self.indicator.stopAnimating()
                        self.newCollectionButton.enabled = true
                    })
                }
            }
            return true
        }
    
    
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
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! InstaMedia
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
            if(animate){
                indicator.startAnimating()
            }
            imageInfoView.hidden = false
            infoLabel.hidden = false
            infoLabel.text = msg
        }else{
            imageInfoView.hidden = true
            infoLabel.hidden = true
            indicator.stopAnimating() //It doesn't hurt to stop animation in case it didn't start before
        }
    }
    
    @IBAction func switchViews(sender: ADVSegmentedControl) {
        switch (sender.selectedIndex) {
        case 0:
            collectionView.hidden = false
            tableView.hidden = true
        case 1:
            collectionView.hidden = true
            tableView.hidden = false
        default:
            break;
        }
        
    }
    
}

