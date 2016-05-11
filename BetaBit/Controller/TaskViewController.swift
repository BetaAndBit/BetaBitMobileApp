//
//  TaskViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 02/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var answerTextField: UITextField!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTask()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        switch toInterfaceOrientation {
        case .LandscapeLeft, .LandscapeRight:
            navigationController?.navigationBar.hidden = true
            tabBarController?.tabBar.hidden = true
        case .Portrait:
            navigationController?.navigationBar.hidden = false
            tabBarController?.tabBar.hidden = false
        default:
            break
        }
    }
    
    private func setupUI() {
        title = task?.name ?? ""
        sendButton.setupRoundRect()
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func loadTask() {
        guard let _ = self.task else { return }
        let url = NSURL(string: apiClient.urlForTask(task))
        webView.loadRequest(NSURLRequest(URL: url!))
    }
    
    private func showIncorrectAnswerAlert() {
        let alertView = UIAlertController(title: NSLocalizedString("Info", comment: ""),
                                          message: NSLocalizedString("Your answer is incorrect", comment: ""),
                                          preferredStyle: .Alert)
        let actionGoBack = UIAlertAction(title: NSLocalizedString("Go Back", comment: ""),
                                         style: .Default) { _ in
            self.navigationController?.popViewControllerAnimated(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let actionTryAgain = UIAlertAction(title: NSLocalizedString("Try again", comment: ""),
                                           style: .Default, handler: nil)
        alertView.addAction(actionGoBack)
        alertView.addAction(actionTryAgain)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    private func showCorrectAnswerAlert() {
        let alertView = UIAlertController(title: NSLocalizedString("Info", comment: ""),
                                          message: NSLocalizedString("Congratulations! \n Your answer is correct!", comment: ""),
                                          preferredStyle: .Alert)
        let actionNextTask = UIAlertAction(title: NSLocalizedString("Next Task", comment: ""),
                                           style: .Default) { _ in
            dataStore.updateData()
            self.navigationController?.popViewControllerAnimated(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertView.addAction(actionNextTask)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        guard let task = self.task else { return }
        
        apiClient.checkAnswer(answerTextField.text ?? "", task: task) { (response) in
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 200:
                self.showCorrectAnswerAlert()
            case 400:
                self.showIncorrectAnswerAlert()
            default:
                break
            }
        }
    }
}
