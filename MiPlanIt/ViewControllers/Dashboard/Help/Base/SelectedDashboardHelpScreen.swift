//
//  SelectedDashboardHelpScreen.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 01/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import UIKit

protocol SelectedDashboardHelpScreenDelegate: AnyObject {
    func selectedDashboardHelpScreenOnClose(_ selectedDashboardHelpScreen: SelectedDashboardHelpScreen)
}

class SelectedDashboardHelpScreen: UIViewController {
    
    weak var delegate: SelectedDashboardHelpScreenDelegate?
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var viewHelp1: UIView!
    @IBOutlet weak var viewHelp2: UIView!
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var buttonOption: UIButton!
    @IBOutlet weak var buttonDownArrow: UIButton!
    @IBOutlet weak var buttomTitle: UIButton!
    
    @IBOutlet var gotItButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initiateView()
    }

    @IBAction func GotIt1Clicked(_ sender: UIButton) {
        self.showHelp2()
    }

    @IBAction func GotIt2Clicked(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.selectedDashboardHelpScreenOnClose(self)
        }
    }

    func initiateView() {
        if let user = Session.shared.readUser() {
            self.imageViewProfilePic.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
        }
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
        self.showHelp1()
        
    }

    func showHelp1() {
        self.viewHelp2.isHidden = true
        self.buttonOption.isHidden = true
        self.viewHelp1.isHidden = false
        self.buttomTitle.isHidden = false
        self.imageViewBG.isHidden = false
        self.imageViewProfilePic.isHidden = false
        self.buttonDownArrow.isHidden = false
    }

    func showHelp2() {
        self.viewHelp2.isHidden = false
        self.buttonOption.isHidden = false
        self.viewHelp1.isHidden = true
        self.buttomTitle.isHidden = true
        self.imageViewBG.isHidden = true
        self.imageViewProfilePic.isHidden = true
        self.buttonDownArrow.isHidden = true
    }
    
}
