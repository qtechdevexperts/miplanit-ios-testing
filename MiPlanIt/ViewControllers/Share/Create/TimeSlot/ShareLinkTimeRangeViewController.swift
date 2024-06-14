//
//  ShareLinkTimeRangeViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class ShareLinkTimeRangeViewController: TimeSlotViewController {
    
    var durationInSeconds: Int = 1800 // 30*60

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userResizableView.borderView?.isUserInteractionEnabled = false
    }

}
