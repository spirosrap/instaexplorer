//
//  InstaLocationsTableViewController.swift
//  instaexplorer
//
//  Created by Spiros Raptis on 08/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class InstaLocationsTableViewController: UITableViewController {
    var instaLocations = [InstaLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.

        
        return instaLocations.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 

        // Configure the cell...
        
        let instaLocation = self.instaLocations[indexPath.row]
        // Set the name and image
        cell.textLabel?.text = instaLocation.name
        cell.detailTextLabel?.text = "latitude:\(instaLocation.latitude) longitude:\(instaLocation.longitude)"
        cell.imageView?.image = UIImage(named: "magglass")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        InstaClient.sharedInstance().getMediaFromLocation(instaLocations[indexPath.row], completionHandler: { (result, error) -> Void in
            if(error == nil){
                
                for m in result! {
                    (m as InstaMedia).instaLocation = self.instaLocations[indexPath.row]
                }
                CoreDataStackManager.sharedInstance().saveContext()
                let paController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationPhotoAlbumViewController") as! LocationPhotoAlbumViewController
                paController.title = self.instaLocations[indexPath.row].name
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.pushViewController(paController, animated: true)
                }
            }else{
                self.displayMessageBox("Could not retrieve images for the location")
            }

        })

    }


    //A simple Alert view with an OK Button
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
