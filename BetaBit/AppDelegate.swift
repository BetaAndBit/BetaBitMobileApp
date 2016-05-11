//
//  AppDelegate.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit

let apiClient = ApiClient()
let dataStore = DataStore()
let sessionManager = SessionManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        IQKeyboardManager.sharedManager().enable = true

        GIDSignIn.sharedInstance().clientID = "yourClientId"

        let _ = sessionManager.isLoggedIn
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return
            FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) ||
            GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
