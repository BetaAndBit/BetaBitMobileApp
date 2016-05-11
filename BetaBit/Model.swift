//
//  Model.swift
//  BetaBit
//
//  Created by Piotr Dudek on 04/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import Decodable

struct Location {
    let id: Int
    let name: String
    let tasks: [Task]
}

extension Location: Decodable {
    static func decode(j: AnyObject) throws -> Location {
        return try Location(
            id: j => "id",
            name: j => "name",
            tasks: j => "tasks"
        )
    }
}

struct Task {
    let id: String
    let locationId: String
    let name: String
    let isDiscovered: Bool
    let isSolved: Bool
}

extension Task: Decodable {
    static func decode(j: AnyObject) throws -> Task {
        return try Task(
            id: j => "task_id",
            locationId: j => "location_id",
            name: j => "name",
            isDiscovered: j => "is_discovered",
            isSolved: j => "is_solved"
        )
    }
}

final class LocationViewModel {
    class func solvedTasksInfo(location: Location) -> String {
        let numberOfTasks = location.tasks.count
        let numberOfSolvedTask = location.tasks.filter{ $0.isSolved }.count
        return "\(NSLocalizedString("Solved tasks: ", comment: "")) \(numberOfSolvedTask)/\(numberOfTasks)"
    }
}
