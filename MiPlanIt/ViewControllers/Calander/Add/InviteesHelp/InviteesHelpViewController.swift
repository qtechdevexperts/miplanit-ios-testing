//
//  InviteesHelpViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class InviteesHelpViewController: UIViewController {
    
    enum HelpRect {
        case fullAccess, partialAccess
    }

    var fullAccessFrameRect: CGRect! = .zero
    var partialAccessFrameRect: CGRect! = .zero
    var activeRect: HelpRect = .fullAccess
    
    @IBOutlet weak var viewSquareHoleView: SquareHoleView!
    
    @IBAction func gotButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
}
