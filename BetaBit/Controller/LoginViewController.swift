//
//  LoginViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var facebookSignIn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        facebookSignIn.readPermissions = ["public_profile", "email"]
        facebookSignIn.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.userDidLogin), name: UserDidLoginNotification, object: nil)
    }

    @IBAction func skipButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidLogin() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if result.grantedPermissions.contains("email") {
            let token = Token(type: .Facebook, string: result.token.tokenString, expirationDate: result.token.expirationDate)
            sessionManager.saveToken(token)
            dataStore.updateData()
            getFacebookUserData()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        sessionManager.logout()
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    private func getFacebookUserData(){
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil) {
                    sessionManager.saveUsername(result["email"]! as! String)
                } else {
                    print("Error when requesting facebook data: \(error)")
                }
            })
        }
    }
}

extension LoginViewController: GIDSignInUIDelegate {
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginViewController: GIDSignInDelegate {
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            let token = Token(type: .Google, string: user.authentication.idToken, expirationDate: user.authentication.idTokenExpirationDate)
            sessionManager.saveToken(token)
            sessionManager.saveUsername(user.profile.name)
            dataStore.updateData()            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            print("Error when signing in with google: \(error)")
        }
    }
}
