//
//  SessionManager.swift
//  BetaBit
//
//  Created by Piotr Dudek on 04/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Locksmith

enum TokenType: Int32 {
    case Google
    case Facebook
}

final class Token: NSObject, NSCoding {
    let type: TokenType
    let string: String
    let expirationDate: NSDate
    
    var didExpire: Bool {
        return expirationDate.timeIntervalSinceNow < 100.0
    }
    
    init(type: TokenType, string: String, expirationDate: NSDate) {
        self.type = type
        self.string = string
        self.expirationDate = expirationDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(type.rawValue, forKey: "type")
        aCoder.encodeObject(string, forKey: "string")
        aCoder.encodeObject(expirationDate, forKey: "expirationDate")
    }
    
    init?(coder aDecoder: NSCoder) {
        type = TokenType(rawValue: aDecoder.decodeIntForKey("type"))!
        string = aDecoder.decodeObjectForKey("string") as! String
        expirationDate = aDecoder.decodeObjectForKey("expirationDate") as! NSDate
    }
    
}

class SessionManager {
    
    var authToken: String {
        return token?.string ?? ""
    }
    
    var isLoggedIn: Bool {
        if let token = self.token {
            return !checkIfTokenDidExpire(token)
        } else {
            return false
        }
    }
    
    var username: String {
        return (NSUserDefaults.standardUserDefaults().valueForKey("username") as? String) ?? ""
    }
    
    private let kUserAccount = ""
    private let kAuthToken = ""
    private let kUsername = ""
    
    private var token: Token? {
        return Locksmith.loadDataForUserAccount("BetaBitApp")?["authToken"] as? Token
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        removeUsername()
        removeToken()
    }
    
    func saveToken(token: Token) {
        do {
            try Locksmith.saveData(["authToken": token], forUserAccount: "BetaBitApp")
            let notification = NSNotification(name: UserDidLoginNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        } catch {
            print("Error when saving token: \(error)")
        }
    }
    
    func saveUsername(username: String) {
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func removeUsername() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func removeToken() {
        do {
            try Locksmith.deleteDataForUserAccount("BetaBitApp")
        } catch {
            print("Error when removing token: \(error)")
        }
    }
    
    private func checkIfTokenDidExpire(token: Token) -> Bool {
        if token.didExpire {
            logout()
            showSessionExpiredAlert()
        }
        return token.didExpire
    }
    
    private func showSessionExpiredAlert() {
        let alertView = UIAlertController(title: NSLocalizedString("Info", comment: ""),
                                          message: NSLocalizedString("Your session has expired. Please login again.", comment: ""),
                                          preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(action)
        
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().delegate?.window?!.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
        }
    }
}
