//
//  ApiClient.swift
//  BetaBit
//
//  Created by Piotr Dudek on 04/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import Alamofire

enum BetaBitTarget {
    case CheckAnswer(locationId: String, taskId: String)
    case GetListOfLocations
    case GetTask(locationId: String, taskId: String)
    case DiscoverTask(locationId: String, taskId: String)

    var endpoint: String {
        switch self {
        case .GetListOfLocations:                           return "/locations/"
        case .GetTask(let locationId, let taskId):          return "/locations/\(locationId)/tasks/\(taskId)"
        case .CheckAnswer(let locationId, let taskId):      return "/locations/\(locationId)/tasks/\(taskId)/check-answer/"
        case .DiscoverTask(let locationId, let taskId):     return "/locations/\(locationId)/tasks/\(taskId)/discover/"
        }
    }
    var apiRoot: String { return "http://betabit.wiki/app/pl" }
    var url: String {
        return apiRoot + endpoint
    }
}

class ApiClient {
    
    var parameters: [String: String] {
        if sessionManager.isLoggedIn {
            return ["Authorization": "Bearer " + reverseToken(sessionManager.authToken)]
        } else {
            return ["Authorization": ""]
        }
    }
    
    func getData(succes:([Location]) -> ()) {
        let url = BetaBitTarget.GetListOfLocations.url
        Alamofire
            .request(.POST, url, parameters: parameters, encoding: .URL, headers: nil)
            .debugLog()
            .responseJSON { response in
                if let json = response.result.value {
                    do {
                        let locations = try [Location].decode(json)
                        dispatch_async(dispatch_get_main_queue(), { 
                            succes(locations)
                        })
                    } catch {
                        print("Error when updating data: \(error)")
                    }
                }
        }
    }
    
    func checkAnswer(answer: String, task: Task, completion: (Response<String, NSError>) -> Void) {
        var parameters = [String:String]()
        parameters = self.parameters
        parameters.updateValue(answer, forKey: "answer")
        
        let url = BetaBitTarget.CheckAnswer(locationId: task.locationId, taskId: task.id).url
        Alamofire
            .request(.POST, url, parameters: parameters, encoding: .URL, headers: nil)
            .debugLog()
            .responseString { (response) in
                dispatch_async(dispatch_get_main_queue(), {
                    completion(response)
                })
            }
    }
    
    func discoverTask(task: Task, completion: (Response<String, NSError>) -> Void) {
        let url = BetaBitTarget.DiscoverTask(locationId: task.locationId, taskId: task.id).url
        Alamofire
            .request(.POST, url, parameters: parameters, encoding: .URL, headers: nil)
            .debugLog()
            .responseString { (response) in
                dispatch_async(dispatch_get_main_queue(), {
                    completion(response)
                })
        }
    }
    
    func urlForTask(task: Task) -> String {
        return BetaBitTarget.GetTask(locationId: task.locationId, taskId: task.id).url
    }
}

func reverseToken(token: String) -> String {
    let reversed = String(token.characters.reverse())
    
    let first10characters = reversed.substringToIndex(reversed.startIndex.advancedBy(10))
    let last10characters = reversed.substringFromIndex(reversed.endIndex.advancedBy(-10))
    
    let coreRange = Range<String.Index>(reversed.startIndex.advancedBy(10)..<reversed.endIndex.advancedBy(-10))
    let core = reversed.substringWithRange(coreRange)
    
    return last10characters + core + first10characters
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}
