//
//  LocationDetailViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit

class LocationDetailViewController: UITableViewController {

    var location: Location?
    var selectedTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationDetailViewController.reloadData), name: DidUpdateLocationsDataNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? TaskViewController {
            viewController.task = selectedTask
        }
    }
    
    func refreshData() {
        dataStore.updateData {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        guard location != nil else { return }
        location = dataStore.findLocation(location!.id)
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = location?.name ?? ""
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        let px = 1 / UIScreen.mainScreen().scale
        let frame = CGRectMake(0, 0, tableView.frame.size.width, px)
        let line: UIView = UIView(frame: frame)
        line.backgroundColor = tableView.separatorColor
        tableView.tableHeaderView = line
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(LocationsListViewController.refreshData), forControlEvents: .ValueChanged)
        self.refreshControl = refreshControll
    }
    
    private func descriptionForTaskStatus(task: Task) -> String {
        if task.isSolved {
            return NSLocalizedString("Solved", comment: "")
        } else if task.isDiscovered {
            return NSLocalizedString("Discovered", comment: "")
        } else {
            return NSLocalizedString("Undiscovered", comment: "")
        }
    }
    
    private func descriptionColorForTaskStatus(task: Task) -> UIColor {
        if task.isSolved {
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:1)
        } else if task.isDiscovered {
            return UIColor.orangeColor()
        } else {
            return UIColor.redColor()
        }
    }
}

extension LocationDetailViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location?.tasks.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.whiteColor()
        
        guard let task = location?.tasks[indexPath.row] else {
            return cell
        }
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = descriptionForTaskStatus(task)
        cell.detailTextLabel?.textColor = descriptionColorForTaskStatus(task)
        return cell
    }
}

extension LocationDetailViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let task = location?.tasks[indexPath.row] where task.isDiscovered || task.isSolved else {
            return
        }
        selectedTask = location?.tasks[indexPath.row]
        performSegueWithIdentifier("showTask", sender: nil)
    }
}
