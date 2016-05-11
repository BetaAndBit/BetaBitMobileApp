//
//  ProfileViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.setupRoundRect()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if sessionManager.isLoggedIn {
            setupUIforLoggedIn()
        } else {
            setupUIforLoggedOut()
        }
    }
    
    @IBAction func loginLogoutTapped(sender: AnyObject) {
        if sessionManager.isLoggedIn {
            sessionManager.logout()
            setupUIforLoggedOut()
            dataStore.updateData()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    private func setupUIforLoggedOut() {
        logoutButton.setTitle(NSLocalizedString("Login", comment: ""), forState: .Normal)
        usernameLabel.hidden = true
        infoLabel.hidden = true
        usernameLabel.text = ""
    }
    
    private func setupUIforLoggedIn() {
        logoutButton.setTitle(NSLocalizedString("Logout", comment: ""), forState: .Normal)
        usernameLabel.text = sessionManager.username
        usernameLabel.hidden = false
        infoLabel.hidden = false
    }
}
