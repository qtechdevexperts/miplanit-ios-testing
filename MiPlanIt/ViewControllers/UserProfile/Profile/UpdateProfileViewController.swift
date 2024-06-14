//
//  UpdateProfileViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class UpdateProfileViewController: ProfileBaseViewController {

    var drawer: NavigationDrawerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func uploadProfileContinueAction() {
        self.drawer?.refreshUI()
        self.buttonUpdateProfile.setTitle(Strings.submit, color: .white)
    }
    
   override func uploadProfilePicAction() {
         self.drawer?.refreshUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .profile
            self.drawer = navigationDrawerViewController
        default: break
        }
    }
}
