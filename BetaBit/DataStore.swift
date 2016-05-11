//
//  DataStore.swift
//  BetaBit
//
//  Created by Piotr Dudek on 07/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation

class DataStore {
    var locations = [Location]()
    
    func updateData(completion: (() -> Void)? = nil) {
        apiClient.getData { locations in
            self.locations = locations
            print(locations)
            let notification = NSNotification(name: DidUpdateLocationsDataNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            completion?()
        }
    }
    
    func findTask(id: String, locationId: String) -> Task? {
        let tasks = locations.flatMap { (location) -> [Task] in
            return location.tasks
        }
        let task = tasks.filter { (task) -> Bool in
            return task.id == id && task.locationId == locationId
        }
        return task.first
    }
    
    func findLocation(id: Int) -> Location? {
        let location = locations.filter { $0.id == id }
        return location.first
    }
}
