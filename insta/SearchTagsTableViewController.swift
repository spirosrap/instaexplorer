//
//  SearcbTagsTableViewController.swift
//  instaplaces
//
//  Created by Spiros Raptis on 15/05/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class SearchTagsTableViewController: UITableViewController,UISearchResultsUpdating {
    
    let tableData:[String] = []
    var filteredTableData = [(String,Int)]()
    var resultSearchController = UISearchController()
    
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = false
        
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
            return self.filteredTableData.count
        }
        else {
            return self.tableData.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // 3
        if (self.resultSearchController.active) {
            if let t = cell.textLabel!.text{
                cell.textLabel?.text = "#" + filteredTableData[indexPath.row].0
               let numberFormatter = NSNumberFormatter()
               numberFormatter.numberStyle = .DecimalStyle
                
               cell.detailTextLabel?.text = numberFormatter.stringFromNumber(filteredTableData[indexPath.row].1)! + " posts"
                
            }
            return cell
        }
        else {
            cell.textLabel?.text = tableData[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.resultSearchController.active) {
//            filteredTableData[indexPath.row]
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("displayTaggedMedia")! as! PhotoAlbumViewController
            InstaClient.sharedInstance().getMediaFromTag(filteredTableData[indexPath.row].0, completionHandler: { (result, error) -> Void in
                if error == nil{
                    dispatch_async(dispatch_get_main_queue(), {
                        detailController.prefetchedPhotos = result! as [InstaMedia]
                        self.resultSearchController.active = false
                        
                        detailController.navigationController?.navigationBar.hidden = false
                        
                        self.navigationController!.pushViewController(detailController, animated: true)
                    })
                }
            })
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c]%@", searchController.searchBar.text)
        
        var array = [(String,Int)]()
        
        InstaClient.sharedInstance().getTags(searchController.searchBar.text, completionHandler: { (result, error) -> Void in
            if error == nil{
                for r in result!{
                    array += [(r.name!,r.media_count!)]
                }
                dispatch_async(dispatch_get_main_queue(), {
                      self.filteredTableData = array
                    self.tableView.reloadData()
                })
            }
        })
//        let array = (tableData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.tableView.reloadData()

        
    }
    

}
