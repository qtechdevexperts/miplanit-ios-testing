//
//  SettingHelpScreenViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SettingHelpScreenViewController: UIViewController {

    var fromAccount: Bool = false
    
    @IBOutlet weak var viewAccountHelp: UIView!
    @IBOutlet weak var viewSettingHelp: UIView!
    
    @IBOutlet var gotItButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initView()
    }
    
    @IBAction func gotButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func initView() {
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
        self.fromAccount ? self.showAccountHelp() : self.showSettingHelp()
    }
    
    func showAccountHelp() {
        self.viewAccountHelp.isHidden = false
        self.viewSettingHelp.isHidden = true
    }
    
    func showSettingHelp() {
        self.viewAccountHelp.isHidden = true
        self.viewSettingHelp.isHidden = false
    }
    

}
