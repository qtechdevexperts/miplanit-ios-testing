//
//  RegisterOTPVerificationViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class RegisterOTPVerificationViewController: OTPVerificationViewController {
    
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func sendOTPToAwsServer() {
        self.verifyOTPWithAWSServer(self.getOTPCode())
    }
    
    override func reSendOTPToAwsServer() {
        self.sendOTPToAWSServerUsingUserName()
    }
    
    override func backToPreviousScreen() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
