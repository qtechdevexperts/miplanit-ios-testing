//
//  AboutUsViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblCopyRight: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
        self.initialiseUIComponents()
    }
    
    //MARK: - IBActions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
