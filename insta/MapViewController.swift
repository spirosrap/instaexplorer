//
//  MapViewController.swift
//  instaplaces
//
//  Created by Spiros Raptis on 07/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tapRecognizer: UITapGestureRecognizer? = nil //Recognizer for the search bar
    var locations = [Location]() // Array of locations in map view.
    var selectedLocation:Location! // The selected location or the just created location using the pin.
    var annotationsLocations = [Int:Location]() //This dictionary is used to save the location together with annotations hash. When a user selects an annotation we can then determine which location was.
    var fetchedPhotos = [InstaMedia]()
    
    var firstDrop = true // This is a variable to determine when it is the first time the user long clicks in order to avoid having the effect of creating an annotation. (In order to create the drag effect we create and remove annotations very fast).(The effect seems like the pin is dropping from outside the phone(up))
    var longPressRecognizer:UILongPressGestureRecognizer!
    
    //MARK: ViewDidLoad,ViewWillAppear,viewWillDisappear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.navigationController?.navigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        restoreMapRegion(false) //Remembers where the user scrolled in the map.
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
//        // Step 2: invoke fetchedResultsController.performFetch(nil) here
        fetchedResultsController.performFetch(nil)
        let sectionInfo = self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
//
//        //Recreate the saved(from Core Data) annotations
        if  !sectionInfo.objects.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
            for l in locations{
                let annotation = MKPointAnnotation()
                var tapPoint = CLLocationCoordinate2D(latitude: Double(l.latitude), longitude: Double(l.longitude)) //We need to cast to double because the parameters were NSNumber
                annotation.coordinate = tapPoint
                annotationsLocations[annotation.hash] = l //Setting the dictionary that will enable us to segway to photo album
                self.mapView.addAnnotation(annotation)
            }
        }
        searchBar.delegate = self
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }

    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {

        switch (sender.selectedSegmentIndex) {
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
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.tabBarController!.tabBar.hidden = false;


        var frcf = fetchedResultsController
        frcf.performFetch(nil)
        let sectionInfo = frcf.sections![0] as! NSFetchedResultsSectionInfo
        
        if  !sectionInfo.objects.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
        }
        
//        imageInfoView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.70)
//        imageInfoView.hidden = true
//        infoLabel.hidden = true
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
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //MARK: search button(geocoding)
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        //Start Geocoding. (Search Button Clicked)
        if let address = searchBar.text{
            var geocoder = CLGeocoder()
//            informationBox("Gecoding...", animate: true) // The information box displays while geocoding
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                if let error = error {
                    var alert = UIAlertController(title: "", message: "Geocoding failed", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.informationBox(nil, animate: false)
                } else {
                    if let placemark = placemarks?[0] as? CLPlacemark {
                        //Center the map
                        let p = MKPlacemark(placemark: placemark)
                        let span = MKCoordinateSpanMake(1, 1)
                        let region = MKCoordinateRegion(center: p.location.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                }
//                self.informationBox(nil, animate: false) //Dismiss information Box
            })
        }
    }
    
    //MARK: Creating annotations
    //Keep an array of annotations to remove in case of user dragging the annotations before it releases his finger
    var annotationsToRemove = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    func longPressed(sender: UILongPressGestureRecognizer) -> Bool//I added a return value to exit when there is no connection
    {
        // Before initiating the searching for photos and creating the annotation check
        // For available internet connection
//        var networkReachability = Reachability.reachabilityForInternetConnection()
//        var networkStatus = networkReachability.currentReachabilityStatus()
//        if(networkStatus.value == NotReachable.value){
//            displayMessageBox("No Network Connection")
//            return false
//        }
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if (sender.state == .Began)
        {
            var annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
            
            firstDrop = true
            let point:CGPoint = sender.locationInView(self.mapView) //The point the user tapped (CGPoint)
            var tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView) //The point the user tapped (CLLocationCoordinate2D)
            
            annotation.coordinate = tapPoint
            self.mapView.addAnnotation(annotation)
            self.annotation = annotation
            annotationsToRemove.append(annotation) //It will be removed next when the user's finger has moved in order to have an effect of moving annotation.
            
        } else if (sender.state == .Changed){
            firstDrop = false //The first annotation of the series in the drag effect is already droped.
            var annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
            self.mapView.removeAnnotations(annotationsToRemove)
            let point:CGPoint = sender.locationInView(self.mapView)//The point the user tapped (CGPoint)
            var tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)//The point the user tapped (CLLocationCoordinate2D)
            annotation.coordinate = tapPoint
            
            self.mapView.addAnnotation(annotation)
            annotationsToRemove.append(annotation)
            self.annotation = annotation
            
        } else if (sender.state == .Ended){//The user has lifted the finger.
            firstDrop = false
            //Create the new Location and save it to the variable selectedLocation
            selectedLocation = Location(dictionary: ["latitude":self.annotation.coordinate.latitude,"longitude":self.annotation.coordinate.longitude], context: sharedContext)
            InstaClient.sharedInstance().getMedia(Double(selectedLocation.latitude), longitude: Double(selectedLocation.longitude), distance: 100, completionHandler: { (result, error) -> Void in
                
                for il in result!{
                    il.location = self.selectedLocation
                }
//                println(result!.count)
                CoreDataStackManager.sharedInstance().saveContext()
                //instantiate the controller and pass the parameter location.
//                let tableController = self.storyboard!.instantiateViewControllerWithIdentifier("InstaLocationsTableViewController")! as! InstaLocationsTableViewController
//                tableController.instaLocations = result! as [InstaLocation]
//                self.annotationsLocations[self.annotation.hash] = self.selectedLocation //add to dictionary of annotations with Locations.
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    //                self.informationBox(nil,animate:false)
//                    self.navigationController!.pushViewController(tableController, animated: true)
//                }
                
                let paController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController")! as! PhotoAlbumViewController
//                paController.title = self.instaLocations[indexPath.row].name
//                
                paController.location = self.selectedLocation
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tabBarController!.tabBar.hidden = true;
                    self.navigationController!.pushViewController(paController, animated: true)
                }
                self.annotationsLocations[self.annotation.hash] = self.selectedLocation //add to dictionary of annotations with Locations.

                self.mapView.deselectAnnotation(self.annotation, animated: false)
                
                
            })
            
//            applicationDelegate.stats.locationsAdded += 1 //Location Added. For Stats.
//            informationBox("Connecting to Flickr",animate:true)
//            Flickr.sharedInstance().populateLocationPhotos(selectedLocation) { (success,photosArray, errorString) in
//                if success {
//                    if let pd = photosArray{//We create the Photo instances from the photosArray and save them.The actual files aren't downloaded yet.
//                        for p in pd{
//                            let photo = Photo(dictionary: ["title":p[0],"imagePath":p[1]], context: self.sharedContext)
//                            photo.location = self.selectedLocation
//                            applicationDelegate.stats.photosDisplayed += 1 //Save statistic of Photos Displayed
//                        }
//                    }
//                    CoreDataStackManager.sharedInstance().saveContext()
//                    //instantiate the controller and pass the parameter location.
//                    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("CollectionView")! as! PhotoAlbumViewController
//                    detailController.location = self.selectedLocation
//                    
//                    self.annotationsLocations[self.annotation.hash] = self.selectedLocation //add to dictionary of annotations with Locations.
//                    
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.informationBox(nil,animate:false)
//                        self.navigationController!.pushViewController(detailController, animated: true)
//                    }
//                    
//                    self.mapView.deselectAnnotation(self.annotation, animated: false)
//                    self.annotationsToRemove = []
//                    
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.informationBox(nil,animate:false)
//                        self.displayMessageBox(errorString!)//Its appropriate at this point to display an Alert
//                        self.mapView.removeAnnotation(self.annotation)
//                        CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
//                        println(errorString!)
//                    })
//                }
//            }
        }
        
        return true
    }
    
    //MARK: MapView Related
    
    //Select Annotation
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController")! as! PhotoAlbumViewController
        if let l = annotationsLocations[view.annotation.hash]{//Determine the location instance from the hash of selected annotation
            detailController.location = l
            selectedLocation = l //Set The selected location as a global variable
            
            if let p = l.instaMedia{
                if p.isEmpty{ //If all the photos of the album were deleted we fetch another batch of Photos.
//                    informationBox("Connecting to Flickr",animate:true)
                    InstaClient.sharedInstance().getMedia(Double(selectedLocation.latitude), longitude: Double(selectedLocation.longitude), distance: 100) { (result, error) -> Void in
                        
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
//                                self.informationBox(nil,animate:false)
                                //instantiate the controller and pass the parameter location.
                                detailController.location = l
                                
                                for il in result!{
                                    il.location = self.selectedLocation
                                }
                                
                                CoreDataStackManager.sharedInstance().saveContext()
                                self.tabBarController!.tabBar.hidden = true;
                                self.navigationController!.pushViewController(detailController, animated: true)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
//                                self.informationBox(nil,animate:false)
                                self.displayMessageBox("No available Photos Found")//Its appropriate at this point to display an Alert
                                self.mapView.removeAnnotation(view.annotation)
                                CoreDataStackManager.sharedInstance().deleteObject(self.selectedLocation)
                                println(error)
                            })
                        }
                    }
                }else{
                    self.tabBarController!.tabBar.hidden = true;
                    self.navigationController!.pushViewController(detailController, animated: true)
                }
            }
        }
        self.mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    
    //Customise the annotation color etc..
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.draggable = false
            
            pinAnnotationView.canShowCallout = false
            firstDrop ? (pinAnnotationView.animatesDrop = true) : (pinAnnotationView.animatesDrop = false) //If the it is the first time the user makes the longpress use the animateDrop, otherwise don't to create an effect of a moving/draggable annotation.
            
            return pinAnnotationView
        }
        
        return nil
    }
    //This is not used. It could be used in case that we wanted a draggable annotation but this isn't feesible because can't have both select and drag.
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if(newState == .Starting){
            if let l = annotationsLocations[view.annotation.hash]{
//                CoreDataStackManager.sharedInstance().deleteObject(l)
            }
        }
        if(newState == .Ending){
            
//            println("change")
            
//            let loc = Location(dictionary: ["latitude":view.annotation.coordinate.latitude,"longitude":view.annotation.coordinate.longitude], context: sharedContext)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }
    
    //MARK:Restore/save Region
    //Save the map region.
    
    //Create the appropriate path to save and retrieve the map region variables
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
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
    
    
    //MARK: Other: alert view and a custom made information Box
    //An alert message box with an OK Button
    func displayMessageBox(message:String){
        var alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //A custom made info box.
//    func informationBox(var msg:String?,let animate:Bool){
//        if let m = msg{
//            if(animate){
//                indicator.startAnimating()
//            }
//            imageInfoView.hidden = false
//            infoLabel.hidden = false
//            infoLabel.text = msg
//        }else{
//            imageInfoView.hidden = true
//            infoLabel.hidden = true
//            indicator.stopAnimating() //It doesn't hurt to stop animation in case it didn't start before
//        }
//    }
    
    //MARK: Core Data related
    //variable to fetch the ,existing saved in core data,locations
    
    
    
}
//MARK: MapViewController extension
/**
*  This extension comforms to the MKMapViewDelegate protocol. This allows
*  the view controller to be notified whenever the map region changes. So
*  that it can save the new region.
*/

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}






