//
//  EventHelpScreenViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class EventHelpScreenViewController: UIViewController {
    
    
    @IBOutlet weak var viewTagHelp: UIView!
    @IBOutlet weak var viewNotifyCalendar: UIView!
    
    @IBOutlet var gotItButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initView()
    }
    
    @IBAction func tagGotClicked(_ sender: UIButton) {
        self.showNotifyCalendarHelp()
    }
    
    @IBAction func notifyGotItClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func initView() {
        self.viewTagHelp.isHidden = false
        self.viewNotifyCalendar.isHidden = true
        gotItButton.forEach({$0.setGradientBackground(colors: UIColor.primaryButtonGradient)})
    }
    
    func showNotifyCalendarHelp() {
        self.viewTagHelp.isHidden = true
        self.viewNotifyCalendar.isHidden = false
    }
    
}
