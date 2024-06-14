//
//  HelpViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 07/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class HelpViewController: SwipeDrawerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController =  segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .help
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .help
        default: break
        }
    }
    
    @IBAction func aboutUsClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func feedbackClicked(_ sender: UIButton) {
        self.sendEmail()
    }

    @IBAction func privacyPolicyTapped(_ sender: UIButton) {
        self.openURL(URL(string: "https://www.miplanit.com/privacy-policy/"))
    }
    
    @IBAction func howitworksTapped(_ sender: UIButton) {
        self.openURL(URL(string: "https://www.miplanit.com/pdfs/help.pdf"))
    
    }
    
    @IBAction func termsConditionsTapped(_ sender: UIButton) {
        self.openURL(URL(string: "https://www.miplanit.com/terms-and-conditions/"))
    }
    
    @IBAction func youtubeTapped(_ sender: UIButton) {
        self.openURL(URL(string: "https://www.youtube.com/channel/UCV6PVD5Zp3KVg8lKiR_4a0w"))
    }
    
    func openURL(_ url: URL?) {
        guard let bURL = url, UIApplication.shared.canOpenURL(bURL) else { return }
        UIApplication.shared.open(bURL, options: [:], completionHandler: nil)
    }
}
