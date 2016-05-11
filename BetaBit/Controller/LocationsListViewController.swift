//
//  LocationsListViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit

class LocationsListViewController: UITableViewController {
    
    private var selectedLocation: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationsListViewController.reloadData), name: DidUpdateLocationsDataNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? LocationDetailViewController {
            viewController.location = selectedLocation
        }
    }
    
    private func setupUI() {
        navigationItem.title = NSLocalizedString("List of Locations", comment: "")
        tabBarItem.title = NSLocalizedString("Tasks", comment: "")
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        let px = 1 / UIScreen.mainScreen().scale
        let frame = CGRectMake(0, 0, tableView.frame.size.width, px)
        let line: UIView = UIView(frame: frame)
        tableView.tableHeaderView = line
        line.backgroundColor = tableView.separatorColor
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(LocationsListViewController.refreshData), forControlEvents: .ValueChanged)
        self.refreshControl = refreshControll
    }
    
    func refreshData() {
        dataStore.updateData { 
            self.refreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension LocationsListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let location = dataStore.locations[indexPath.row]
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = LocationViewModel.solvedTasksInfo(location)
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
}

extension LocationsListViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedLocation = dataStore.locations[indexPath.row]
        performSegueWithIdentifier("showTasksList", sender: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
}
