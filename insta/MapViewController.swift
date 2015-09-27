//
//  MapViewController.swift
//  instaexplorer
//  Handles the Map (1st tab)
//  Created by Spiros Raptis on 07/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var segment: ADVSegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var alert:UIAlertController!
    var tapRecognizer: UITapGestureRecognizer? = nil //Recognizer for the search bar
    var locations = [Location]() // Array of locations in map view.
    var selectedLocation:Location! // The selected location or the just created location using the pin.
    var annotationsLocations = [Int:Location]() //This dictionary is used to save the location together with annotations hash. When a user selects an annotation we can then determine which location was.
    var fetchedPhotos = [InstaMedia]()
    
    var firstDrop = true // This is a variable to determine when it is the first time the user long clicks in order to avoid having the effect of creating an annotation. (In order to create the drag effect we create and remove annotations very fast).(The effect seems like the pin is dropping from outside the phone(up))
    var longPressRecognizer:UILongPressGestureRecognizer!
    var editButton:UIBarButtonItem!
    var logoutButton = UIBarButtonItem()
    
    
    //MARK: ViewDidLoad,ViewWillAppear,viewWillDisappear
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        self.navigationItem.hidesBackButton = true
        restoreMapRegion(false) //Remembers where the user scrolled in the map.
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        let sectionInfo = self.fetchedResultsController.sections![0] 

        //Recreate the saved(from Core Data) annotations
        if  !sectionInfo.objects!.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
            for l in locations{
                let annotation = MKPointAnnotation()
                let tapPoint = CLLocationCoordinate2D(latitude: Double(l.latitude), longitude: Double(l.longitude)) //We need to cast to double because the parameters were NSNumber
                annotation.coordinate = tapPoint
                annotation.title = " "
                annotationsLocations[annotation.hash] = l //Setting the dictionary that will enable us to segway to photo album
                self.mapView.addAnnotation(annotation)
            }
        }
        searchBar.delegate = self
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        //setup custom segmented control
        segment.items = ["Standard", "Satellite","Hybrid"]
        segment.font = UIFont(name: "Avenir-Black", size: 12)
        segment.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segment.selectedIndex = 0
        segment.addTarget(self, action: "switchSegmented:", forControlEvents: .ValueChanged)
        
        
        editButton = UIBarButtonItem(title: "Delete", style: .Done, target: self, action: "edit")
        logoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "logout")
        
        self.navigationItem.leftBarButtonItem = editButton
        self.navigationItem.rightBarButtonItem = logoutButton
        
        self.editing = false
    }
    //change the label to indicate when we are in edit mode
    func edit(){
        if editButton.title! == "Done"{
            editButton.title = "Delete"
            editButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
        }else{
            editButton.title = "Done"
            editButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.redColor()], forState: UIControlState.Normal)
            
            for a in mapView.annotations{ //Deselect callout bubbles.
                mapView.deselectAnnotation(a , animated: false)
            }
        }
        self.editing = !self.editing
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //Select type of map
    func switchSegmented(sender: ADVSegmentedControl) {

        switch (sender.selectedIndex) {
          case 0:
            mapView.mapType = .Standard
          case 1:
            mapView.mapType = .Satellite
          case 2:
            mapView.mapType = .Hybrid
          default:
            break;
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        self.tabBarController!.tabBar.hidden = false;

    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.hidden = false;


        let frcf = fetchedResultsController
        do {
            try frcf.performFetch()
        } catch _ {
        }
        let sectionInfo = frcf.sections![0] 
        
        if  !sectionInfo.objects!.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
        }
        

        self.addKeyboardDismissRecognizer()
    }
    
    
    //MARK: Core Data related
    //variable to fetch the ,existing saved in core data,locations
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Location")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    func instaMediafetchedResultsController(location:Location) -> NSFetchedResultsController  {
        
        let fetchRequest = NSFetchRequest(entityName: "InstaMedia")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", location);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //MARK: search button(geocoding)
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        
        if(networkStatus.rawValue == NotReachable.rawValue){
            displayMessageBox("No Network Connection")
        } else{
            //Start Geocoding. (Search Button Clicked)
            if let address = searchBar.text{
                let geocoder = CLGeocoder()
                //            informationBox("Gecoding...", animate: true) // The information box displays while geocoding
                self.indicator.startAnimating()
                geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                    if let _ = error {
                        self.indicator.stopAnimating()
                        let alert = UIAlertController(title: "", message: "Geocoding failed", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        //                    self.informationBox(nil, animate: false)
                    } else {
                        self.indicator.stopAnimating()
                        if let placemark = placemarks?[0]  {
                            //Center the map
                            let p = MKPlacemark(placemark: placemark)
                            let span = MKCoordinateSpanMake(1, 1)
                            let region = MKCoordinateRegion(center: p.location!.coordinate, span: span)
                            self.mapView.setRegion(region, animated: true)
                        }
                    }
                    //                self.informationBox(nil, animate: false) //Dismiss information Box
                })
            }
        }
        
    }
    
    //MARK: Creating annotations
    //Keep an array of annotations to remove in case of user dragging the annotations before it releases his finger
    var annotationsToRemove = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    func longPressed(sender: UILongPressGestureRecognizer) -> Bool//I added a return value to exit when there is no connection
    {

        searchBar.resignFirstResponder()
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        
        if(networkStatus.rawValue == NotReachable.rawValue){// Before searching fοr Photos in Instagram check if there is an available internet connection
            displayMessageBox("No network connection")
            return false
        }
        
        if(!self.editing){
            _ = (UIApplication.sharedApplication().delegate as! AppDelegate)
            if (sender.state == .Began)
            {
                firstDrop = true
                
                let annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
                
                let point:CGPoint = sender.locationInView(self.mapView) //The point the user tapped (CGPoint)
                let tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView) //The point the user tapped (CLLocationCoordinate2D)
                
                annotation.coordinate = tapPoint
                self.mapView.addAnnotation(annotation)
                self.annotation = annotation
                annotationsToRemove.append(annotation) //It will be removed next when the user's finger has moved in order to have an effect of moving annotation.
                
            } else if (sender.state == .Changed){
                firstDrop = false //The first annotation of the series in the drag effect is already droped.
                let annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
                self.mapView.removeAnnotations(annotationsToRemove)
                let point:CGPoint = sender.locationInView(self.mapView)//The point the user tapped (CGPoint)
                let tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)//The point the user tapped (CLLocationCoordinate2D)
                annotation.coordinate = tapPoint
                
                self.mapView.addAnnotation(annotation)
                annotationsToRemove.append(annotation)
                self.annotation = annotation
                
            } else if (sender.state == .Ended){//The user has lifted the finger.
                firstDrop = false
                
                indicator.startAnimating()
                //Create the new Location and save it to the variable selectedLocation
                selectedLocation = Location(dictionary: ["latitude":self.annotation.coordinate.latitude,"longitude":self.annotation.coordinate.longitude], context: sharedContext)
                InstaClient.sharedInstance().getMedia(Double(selectedLocation.latitude), longitude: Double(selectedLocation.longitude), distance: 100, completionHandler: { (result, error) -> Void in
                    if error == nil{
                        if(result! != []){
                            self.annotation.title = " "
                            for il in result!{ //associate all the returned objects with the selected location
                                il.location = self.selectedLocation
                            }
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            
                            let paController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationPhotoAlbumViewController") as! LocationPhotoAlbumViewController
                            paController.location = self.selectedLocation
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tabBarController!.tabBar.hidden = true;
                                self.indicator.stopAnimating()
                                self.navigationController!.pushViewController(paController, animated: true)
                            }
                            
                            self.annotationsLocations[self.annotation.hash] = self.selectedLocation //add to dictionary of annotations with Locations.
                            
                            //set the first image for annotation view
                            let view = self.mapView.viewForAnnotation(self.annotation)
                            let imv = UIImageView(frame: view!.frame)
                            let im = result![0] as InstaMedia
                            InstaClient.sharedInstance().setImage(im.imagePath!, imageView: imv)
                            
                            self.mapView.viewForAnnotation(self.annotation)!.leftCalloutAccessoryView = imv //It will display the first image as the accecory view but it's really a random image. It will be changed in subsequent runs.
                            self.mapView.viewForAnnotation(self.annotation)!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                            self.mapView.deselectAnnotation(self.annotation, animated: false)
                            self.annotationsToRemove = []
                            
                        }else{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayMessageBox("No images Found")
                                self.indicator.stopAnimating()
                                self.mapView.deselectAnnotation(self.annotation, animated: false)
                                self.mapView.removeAnnotation(self.annotation)
                                CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                            }
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.displayMessageBox("Error retrieving images for location: \(error!.userInfo)")
                            self.indicator.stopAnimating()
                            self.mapView.deselectAnnotation(self.annotation, animated: false)
                            self.mapView.removeAnnotation(self.annotation)
                            CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                        }
                    }
                })
            }
        }else{
            self.displayMessageBox("You are in Edit Mode! Tap Done.")
        }
        return true
    }
    
    //MARK: Map Related
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let networkReachability = Reachability.reachabilityForInternetConnection()
            let networkStatus = networkReachability.currentReachabilityStatus()
            

            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationPhotoAlbumViewController") as! LocationPhotoAlbumViewController
            if let l = annotationsLocations[annotationView.annotation!.hash]{//Determine the location instance from the hash of selected annotation
                detailController.location = l
                selectedLocation = l //Set The selected location as a global variable
                
                if let p = l.instaMedia{
                    if p.isEmpty{ //If all the photos of the album were deleted we fetch another batch of Photos.
                        if(networkStatus.rawValue == NotReachable.rawValue){
                            displayMessageBox("No network connection")
                        } else{
                            indicator.startAnimating()
                            
                            InstaClient.sharedInstance().getMedia(Double(selectedLocation.latitude), longitude: Double(selectedLocation.longitude), distance: 100) { (result, error) -> Void in
                                
                                if error == nil {
                                    if(result! != []){
                                        dispatch_async(dispatch_get_main_queue()) {
                                            //                                self.informationBox(nil,animate:false)
                                            //instantiate the controller and pass the parameter location.
                                            detailController.location = l
                                            
                                            for il in result!{//associate all the returned objects with the selected location
                                                il.location = self.selectedLocation
                                            }
                                            
                                            CoreDataStackManager.sharedInstance().saveContext()
                                            self.tabBarController!.tabBar.hidden = true;
                                            self.indicator.stopAnimating()
                                            self.navigationController!.pushViewController(detailController, animated: true)
                                        }
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.indicator.stopAnimating()
                                            self.displayMessageBox("No images for that location")//Its appropriate at this point to display an Alert
                                        })
                                    }
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        //                                self.informationBox(nil,animate:false)
                                        self.displayMessageBox("Error retrieving images: \(error!.userInfo)")//Its appropriate at this point to display an Alert
                                        self.mapView.removeAnnotation(annotationView.annotation!)
                                        self.indicator.stopAnimating()
                                        CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                                        print(error)
                                    })
                                }
                            }
                        }

                    }else{
                        self.tabBarController!.tabBar.hidden = true;
                        self.navigationController!.pushViewController(detailController, animated: true)
                    }
                }
            }
        }
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        if annotation is MKPointAnnotation {
            firstDrop ? (pinView.animatesDrop = true) : (pinView.animatesDrop = false) //If the it is the first time the user makes the longpress use the animateDrop, otherwise don't to create an effect of a moving/draggable annotation.
            pinView.pinTintColor = UIColor.purpleColor()
            pinView.canShowCallout = true
            pinView.draggable = true
            let imv = UIImageView(frame: pinView.frame)
            if let _ = annotationsLocations[annotation.hash]{ //find the location for the specific annotation and fetch the first image
                let frcf = instaMediafetchedResultsController(annotationsLocations[annotation.hash]!)
                do {
                    try frcf.performFetch()
                } catch _ {
                }
                let sectionInfo = frcf.sections![0] 
                
                if  !sectionInfo.objects!.isEmpty{
                    var im  = sectionInfo.objects as! [InstaMedia]
                    InstaClient.sharedInstance().setImage(im[0].imagePath!, imageView: imv)
                    pinView.leftCalloutAccessoryView = imv
                }
                
            }
            
        }
        else {
            pinView.annotation = annotation
        }
           pinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)

        return pinView
    }
    
    // Selecting is used when the user pressed the delete button to delete an annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if(self.editing){
            mapView.deselectAnnotation(view.annotation, animated: false)
            let refreshAlert = UIAlertController(title: "Delete Action", message: "Are you Sure you want to delete this location and its images?", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Destructive, handler: { (action: UIAlertAction) in
                self.deleteLocationAnnotationImages(view.annotation!)
                self.annotationsLocations[view.annotation!.hash] = nil
                mapView.removeAnnotation(view.annotation!)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {(action: UIAlertAction) in
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        }

    }
    
    //Dragging an image
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if(newState == .Starting){
            self.deleteLocationAnnotationImages(view.annotation!)
        }
        
        if(newState == .Ending){

            
            //Create the new Location and save it to the variable selectedLocation
            selectedLocation = Location(dictionary: ["latitude":view.annotation!.coordinate.latitude,"longitude":view.annotation!.coordinate.longitude], context: sharedContext)
            annotationsLocations[view.annotation!.hash] = selectedLocation
            
            let networkReachability = Reachability.reachabilityForInternetConnection()
            let networkStatus = networkReachability.currentReachabilityStatus()
            if(networkStatus.rawValue == NotReachable.rawValue){
                displayMessageBox("No network connection")
                self.mapView.deselectAnnotation(view.annotation, animated: false)
                self.mapView.removeAnnotation(view.annotation!)
                CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                CoreDataStackManager.sharedInstance().saveContext()
            }else{
                indicator.startAnimating()
                InstaClient.sharedInstance().getMedia(Double(selectedLocation.latitude), longitude: Double(selectedLocation.longitude), distance: 100, completionHandler: { (result, error) -> Void in
                    if(error == nil){
                        if(result! != []){
                            self.annotation.title = " "
                            for il in result!{ //associate all the returned objects with the selected location
                                il.location = self.selectedLocation
                            }
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            
                            let paController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationPhotoAlbumViewController") as! LocationPhotoAlbumViewController
                            paController.location = self.selectedLocation
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                //                        self.tabBarController!.tabBar.hidden = true;
                                self.annotationsLocations[view.annotation!.hash] = self.selectedLocation //add to dictionary of annotations with Locations.
                                
                                //set the first image for annotation view
                                let view = self.mapView.viewForAnnotation(view.annotation!)
                                let imv = UIImageView(frame: view!.frame)
                                let im = result![0] as InstaMedia
                                InstaClient.sharedInstance().setImage(im.imagePath!, imageView: imv)
                                
                                self.mapView.viewForAnnotation(view!.annotation!)!.leftCalloutAccessoryView = imv //It will display the first image as the accecory view but it's really a random image. It will be changed in subsequent runs.
                                self.mapView.viewForAnnotation(view!.annotation!)!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                                self.mapView.deselectAnnotation(view!.annotation!, animated: false)
                                self.indicator.stopAnimating()
                                self.navigationController!.pushViewController(paController, animated: true)
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.indicator.stopAnimating()
                                self.displayMessageBox("No results found")
                                self.mapView.deselectAnnotation(view.annotation, animated: false)
                                self.mapView.removeAnnotation(view.annotation!)
                                CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                                CoreDataStackManager.sharedInstance().saveContext()
                            }
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.indicator.stopAnimating()
                            self.displayMessageBox("Network error")
                        }
                    }
                })
            }

            
        }
    }
    
    //Delete the images associated with the selected location
    func deleteLocationAnnotationImages(annotation:MKAnnotation){
        let frcf = instaMediafetchedResultsController(annotationsLocations[annotation.hash]!)
        do {
            try frcf.performFetch()
        } catch _ {
        }
        let sectionInfo = frcf.sections![0] 
        
        if  !sectionInfo.objects!.isEmpty{
            let im  = sectionInfo.objects as! [InstaMedia]
            for p in im{
                if(p.favorite != 1){ //Delete all except the favorited ones
                    CoreDataStackManager.sharedInstance().deleteObject(p)
                    CoreDataStackManager.sharedInstance().saveContext()
                }else{
                    p.location = nil
                }
            }
        }
        CoreDataStackManager.sharedInstance().deleteObject(annotationsLocations[annotation.hash]!)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    //MARK:Restore/save Region
    //Save the map region.
    
    //Create the appropriate path to save and retrieve the map region variables
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
        
    }
    
    //Remembers where the user scrolled in the map.
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(savedRegion, animated: animated)
        }else{
            let span = MKCoordinateSpanMake(80, 80)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.628595, longitude: 22.945351), span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    //Action to dismiss the keyboard when a tap was performed outside the text view
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    //MARK: Other:
    //An alert message box with an OK Button
    var isAlertPresented = false //Don't show another alert view if this one is already presenting
    func displayMessageBox(message:String){
        if(!isAlertPresented){
            isAlertPresented = true
            alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                alert in
                    self.isAlertPresented = false

            }))
            self.presentViewController(self.alert, animated: true, completion: nil)
        }
    }
    
    
    
    func logout(){
        InstaClient.sharedInstance().logout(self)
        
        let appDelegateTemp = UIApplication.sharedApplication().delegate
        
        let rootController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        appDelegateTemp!.window!!.rootViewController = rootController;
        
    }
    
    
}
//MARK: MapViewController extension
/**
*  This extension comforms to the MKMapViewDelegate protocol. This allows
*  the view controller to be notified whenever the map region changes. So
*  that it can save the new region.
*/

extension MapViewController {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}






