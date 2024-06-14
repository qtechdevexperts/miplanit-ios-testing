//
//  NotifyCalendarHelpScreen.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 01/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class NotifyCalendarHelpScreen: UIViewController {

    @IBOutlet weak var gotItButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        gotItButton.setGradientBackground(colors: UIColor.primaryButtonGradient)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotitClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    

}
