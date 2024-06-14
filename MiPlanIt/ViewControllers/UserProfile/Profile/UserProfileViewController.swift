//
//  InitialProfileUpdateViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class UserProfileViewController: ProfileBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "test", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ConfigureKeys.purchaseFeatureEnabled {
            self.performSegue(withIdentifier: Segues.segueToPricing, sender: true)
        }
    }
    
    //MARK: - Override functions
    override func uploadProfileSkipAction() {
        if let email = self.textFieldEmail.text, let phone = self.textFieldPhone.text, email.isEmpty, phone.isEmpty {
            self.showAlertWithAction(message: Message.skipMessage, items: [Message.goBack, Message.ok]) { (index) in
                if index == 0 {
                    self.performSegue(withIdentifier: Segues.toImportScreen, sender: self)
                }
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toImportScreen, sender: self)
        }
    }
    
    override func uploadProfileContinueAction() {
        self.performSegue(withIdentifier: Segues.toImportScreen, sender: self)
    }
}
