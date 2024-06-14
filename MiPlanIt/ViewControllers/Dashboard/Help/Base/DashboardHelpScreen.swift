//
//  DashboardHelpScreen.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

class DashboardHelpScreen: UIViewController {
    
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewAddHelp: UIView!
    @IBOutlet weak var viewListHelp: UIView!
    @IBOutlet weak var viewCenterProfileHelp: UIView!
    
    @IBOutlet var gotItButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initiateView()
    }
    
    override func viewDidLayoutSubviews() {
        self.imageViewProfile.cornurRadius = self.imageViewProfile.frame.size.width / 2
    }
    
    @IBAction func profileGotItClicked(_ sender: UIButton) {
        self.showListHelp()
    }
    
    @IBAction func listGotItClicked(_ sender: UIButton) {
        self.showAddHelp()
    }
    
    @IBAction func addGotItClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func initiateView() {
        if let user = Session.shared.readUser() {
            self.imageViewProfile.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
        }
        self.showProfileHelp()
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
    }
    
    func showProfileHelp() {
        self.viewAddHelp.isHidden = true
        self.viewListHelp.isHidden = true
        self.viewCenterProfileHelp.isHidden = false
    }
    
    func showListHelp() {
        self.viewAddHelp.isHidden = true
        self.viewListHelp.isHidden = false
        self.viewCenterProfileHelp.isHidden = true
    }
    
    func showAddHelp() {
        self.viewAddHelp.isHidden = false
        self.viewListHelp.isHidden = true
        self.viewCenterProfileHelp.isHidden = true
    }
    
}
