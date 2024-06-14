//
//  CalendarHelpScreenViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarHelpScreenViewController: UIViewController {
    
    var planItCalendars: [PlanItCalendar] = []
    
    @IBOutlet weak var viewForImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet var gotItButton: [UIButton]!
    @IBOutlet weak var viewHelp1: UIView!
    @IBOutlet weak var viewHelp2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initView()
    }
    
    
    @IBAction func help1GotClicked(_ sender: UIButton) {
        self.showHelp2()
    }
    
    @IBAction func goitClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func initView() {
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
        self.showHelp1()
    }
    
    func showHelp1() {
        if let user = Session.shared.readUser() {
            self.imageView.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
        }
        self.buttonPlus.isHidden = true
        self.viewHelp2.isHidden = true
    }
    
    func showHelp2() {
        self.viewHelp1.isHidden = true
        self.viewForImage.isHidden = true
        self.buttonPlus.isHidden = false
        self.viewHelp2.isHidden = false
    }
}
