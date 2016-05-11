//
//  QRScannerViewController.swift
//  BetaBit
//
//  Created by Piotr Dudek on 08/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class QRScannerViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var captureLayer: CALayer!
    
    private var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.title = NSLocalizedString("Scan QR Code", comment: "")
        tabBarItem.title = NSLocalizedString("Scan", comment: "")
        setupReader()
        startReading()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startReading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.stopRunning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? TaskViewController {
            vc.task = task
        }
    }
    
    private func setupReader() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
            let captureOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureOutput)
            
            let queue = dispatch_queue_create("com.BetaBit.qrScanning", nil)
            captureOutput.setMetadataObjectsDelegate(self, queue: queue)
            captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            captureLayer.frame = view.layer.bounds
            view.layer.addSublayer(captureLayer)
        } catch let error {
            print("Error when setting up QR reader: \(error)")
        }
    }
    
    private func startReading() {
        captureSession.startRunning()
    }
    
    private func discoverTask(task: Task) {
        if sessionManager.isLoggedIn {
            apiClient.discoverTask(task, completion: { (response) in
                if response.response?.statusCode == 200 {
                    dataStore.updateData()
                    self.showTask(dataStore.findTask(task.id, locationId: task.locationId))
                } else {
                    print("error when discovering task")
                }
            })
        } else {
            dataStore.updateData()
            showTask(dataStore.findTask(task.id, locationId: task.locationId))
        }
    }
    
    private func showTask(task: Task?) {
        guard let _ = task else { return }
        self.task = task
        performSegueWithIdentifier("showTask", sender: nil)
    }
    
    private func getTaskId(message: String) {
        let result = Regex.listGroups(".*(\\d{1,}):(\\d{1,}):.*", inString: message)
        guard result.count >= 3 else { return }
        
        let task = Task(id: result[2], locationId: result[1], name: "", isDiscovered: true, isSolved: false)
        discoverTask(task)
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            captureSession.stopRunning()
            dispatch_async(dispatch_get_main_queue()) {
                self.getTaskId(object.stringValue)
            }
        }
    }
}
