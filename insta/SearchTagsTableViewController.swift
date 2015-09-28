//
//  SearchTagsTableViewController.swift
//  instaexplorer
//
//  Created by Spiros Raptis on 15/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import CoreData

class SearchTagsTableViewController: UITableViewController,UISearchResultsUpdating {
    
    let tableData:[String] = []
    var filteredTableData = [Tag]()
    var tags = [Tag]()
    var resultSearchController = UISearchController()
    var temporaryContext: NSManagedObjectContext!
    var editButton:UIBarButtonItem!
    var logoutButton = UIBarButtonItem()
    var indicator:UIActivityIndicatorView!
    var alert:UIAlertController!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        self.tableView.reloadData()
        self.resultSearchController.searchBar.barTintColor = UIColor.blackColor()
        self.resultSearchController.searchBar.tintColor = UIColor.whiteColor()
        
        
        var frame:CGRect = self.tableView.bounds;
        frame.origin.y = -frame.size.height;
        let blackView:UIView = UIView(frame: frame)
        blackView.backgroundColor = UIColor.blackColor()
        self.tableView.addSubview(blackView)


        
        editButton = UIBarButtonItem(title: "Edit", style: .Done, target: self, action: "edit")
        logoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
        self.navigationItem.leftBarButtonItem = editButton
        
        self.editing = false
        self.tableView.editing = false
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.color = UIColor.blackColor()
        indicator.backgroundColor = UIColor.whiteColor()
        indicator.center = self.tableView.center
        indicator.hidesWhenStopped = true
        self.tableView.addSubview(indicator)
        //hide keyboard when scrolling in table view http://stackoverflow.com/questions/4399357/hide-keyboard-when-scroll-uitableview
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() //There was a bug with properly displaying the rounded profile images. It needed to hide and redisplay the view to display properly. With reloading data, it displays correctly
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if (self.resultSearchController.active) {
            if(self.tableView.editing){
               //Disable editing if the user forgot to tap done
            editButton.title = "Edit"
            self.tableView.editing = !self.tableView.editing

            }
            return self.filteredTableData.count
        }
        else {
            do {
                try fetchedResultsController.performFetch()
            } catch _ {
            }
            tags = self.fetchedResultsController.fetchedObjects! as! [Tag]
            return tags.count
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Tag")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    //Fetch controller for Media which has already associated with a searched tag.
    func fetchedTaggedMediaResultsController(let tag:Tag) -> NSFetchedResultsController  {
        
        let fetchRequest = NSFetchRequest(entityName: "InstaMedia")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "tag == %@", tag);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        // 3
        if (self.resultSearchController.active) {
            temporaryContext.performBlockAndWait(){
            if let _ = cell.textLabel!.text,let name = self.filteredTableData[indexPath.row].name, let media_count = self.filteredTableData[indexPath.row].media_count{
                    
                    cell.textLabel?.text = "#" + name
                    cell.detailTextLabel?.text = numberFormatter.stringFromNumber(media_count)! + " posts"
                    
            }
            }
            return cell
        }
        else {
            if let _ = cell.textLabel!.text{
                cell.textLabel?.text = "#" + tags[indexPath.row].name!
                cell.detailTextLabel?.text = " "
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("displayTaggedMedia") as! PhotoAlbumViewController
        
        if (self.resultSearchController.active) {
            
            temporaryContext.performBlockAndWait(){
                
                if let _ = self.filteredTableData[indexPath.row].name,let _ = self.filteredTableData[indexPath.row].media_count {

                        let selectedTag = self.filteredTableData[indexPath.row].name!
                        
                        var dictionary = [String:AnyObject]()
                        
                        dictionary["name"] = self.filteredTableData[indexPath.row].name!
                        dictionary["media_count"] = self.filteredTableData[indexPath.row].media_count!
                        
                        let savedTag = Tag(dictionary: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext!)
                    
                        CoreDataStackManager.sharedInstance().saveContext()
                        self.indicator.startAnimating()

                            InstaClient.sharedInstance().getMediaFromTag(selectedTag, completionHandler: { (result, error) -> Void in
                                if error == nil{
                                    if result! != []{
                                        dispatch_async(dispatch_get_main_queue(), {
                                            detailController.prefetchedPhotos = result! as [InstaMedia]
                                            for r in result!{
                                                r.tag = savedTag
                                            }
                                            CoreDataStackManager.sharedInstance().saveContext()
                                            detailController.navigationController?.navigationBar.hidden = false
                                            detailController.navigationItem.title =   "#" + selectedTag
                                            self.indicator.stopAnimating()
                                            self.resultSearchController.active = false
                                            self.navigationController!.pushViewController(detailController, animated: true)
                                        })
                                    }else{
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.indicator.stopAnimating()
                                            self.displayMessageBox("No images for that hashtag found")
                                        }
                                    }
                                }
                            })
                    
                }else{
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }else{
            let selectedTag = tags[indexPath.row]
            let frc = fetchedTaggedMediaResultsController(selectedTag)
            do {
                try frc.performFetch()
            } catch _ {
            }
            let media = frc.fetchedObjects! as! [InstaMedia]
            detailController.prefetchedPhotos = media
            
            detailController.navigationController?.navigationBar.hidden = false
            detailController.navigationItem.title =   "#" + selectedTag.name!

            self.navigationController!.pushViewController(detailController, animated: true)

            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //For deleting the Meme
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let selectedTag = tags[indexPath.row]
        let frc = fetchedTaggedMediaResultsController(selectedTag)
        do {
            try frc.performFetch()
        } catch _ {
        }
        let media = frc.fetchedObjects! as! [InstaMedia]

        for m in media{
            if m.favorite != 1{
                CoreDataStackManager.sharedInstance().deleteObject(m)
            }else{
                m.tag = nil // We need to deassociate the favorited media from this tag because it's going to be deleted
            }
        }
        
        CoreDataStackManager.sharedInstance().deleteObject(tags[indexPath.row])
        editButton.title = "Edit"
        self.tableView.editing = !self.tableView.editing
        tableView.reloadData()
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let networkReachability = Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus()
        if(networkStatus.rawValue == NotReachable.rawValue){// Before searching fοr  additional Photos in instagram check if there is an available internet connection
            displayMessageBox("No Network Connection")
            searchController.active = false
            self.tableView.reloadData()
        }else{
            filteredTableData.removeAll(keepCapacity: false)
            _ = NSPredicate(format: "SELF CONTAINS[c]%@", searchController.searchBar.text!)
            
            var array = [Tag]()
            
            // Set the temporary context
            // When getting any tags we don't need them for the main context and we create a temporary one
            let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
            
            temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            temporaryContext.parentContext = sharedContext
            if(searchController.searchBar.text != ""){
                indicator.startAnimating()
                
                

                InstaClient.sharedInstance().getTags(searchController.searchBar.text!,context: self.temporaryContext, completionHandler: { (result, error) -> Void in
                    if error == nil{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            for r in result!{
                                array += [r as Tag]
                            }
                            self.indicator.stopAnimating()
                            self.filteredTableData = array
                            self.tableView.reloadData()
                            
                        })
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayMessageBox("Error searching for tags")
                            self.indicator.stopAnimating()

                        })
                        
                    }
                })
         
        }
       self.tableView.reloadData()
    }
        
    }
    
    //change the label to indicate when we are in edit mode
    func edit(){
        if editButton.title! == "Edit"{
            editButton.title = "Done"
        }else{
            editButton.title = "Edit"
        }
        self.tableView.editing = !self.tableView.editing
        self.tableView.reloadData()
    }
    
    func logout(){
        InstaClient.sharedInstance().logout(self)
        
        let appDelegateTemp = UIApplication.sharedApplication().delegate
        
        let rootController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        appDelegateTemp!.window!!.rootViewController = rootController;

    }

    //MARK: Other: alert view and a custom made information Box
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


}
