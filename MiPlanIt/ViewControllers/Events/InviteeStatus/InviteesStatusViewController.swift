//
//  InviteesStatusViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class InviteesStatusViewController: UIViewController {
    
    var invitees: [OtherUser] = []

    // MARK:-IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
