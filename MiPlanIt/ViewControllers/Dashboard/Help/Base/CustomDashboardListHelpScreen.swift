//
//  CustomDashboardListHelpScreen.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 01/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class CustomDashboardListHelpScreen: UIViewController {

    @IBOutlet weak var viewAddHelp: UIView!
    @IBOutlet weak var viewSwipeLefttHelp: UIView!
    @IBOutlet weak var viewSwipeRightHelp: UIView!
    @IBOutlet var gotItButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
        self.showSwipeleftHelp()
    }
        
    @IBAction func swipeLeftGotItClicked(_ sender: UIButton) {
        self.showSwipeRightHelp()
    }
    
    @IBAction func swipeRightGotItClicked(_ sender: UIButton) {
        self.showAddHelp()
    }
    
    @IBAction func addGotItClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

    func showSwipeleftHelp() {
        self.viewAddHelp.isHidden = true
        self.viewSwipeRightHelp.isHidden = true
        self.viewSwipeLefttHelp.isHidden = false
    }
    
    func showSwipeRightHelp() {
        self.viewAddHelp.isHidden = true
        self.viewSwipeRightHelp.isHidden = false
        self.viewSwipeLefttHelp.isHidden = true
    }
    
    func showAddHelp() {
        self.viewAddHelp.isHidden = false
        self.viewSwipeRightHelp.isHidden = true
        self.viewSwipeLefttHelp.isHidden = true
    }
    
}
