//
//  DataStorageViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class DataStorageViewController: UIViewController {
    
    lazy var userStorage: PlanItDataStorage? = {
        return DatabasePlanItDataStorage().readUsersDataStorage().first
    }()
    
    @IBOutlet weak var labelTotalSpace: UILabel!
    @IBOutlet weak var labelUsedSpace: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var buttonLoader: ProcessingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initilizeView()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
