//
//  SettingsViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SettingsViewController: SwipeDrawerViewController {
    
    var isFetchingLinkExipryTime: Bool = false

    @IBOutlet weak var imageViewExpiryIcon: UIImageView!
    @IBOutlet weak var buttonLinkExpirySpinner: ProcessingButton!
    @IBOutlet weak var labelEventLinkExpiry: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
        self.addNotifications()
        self.createServiceForLinkExpiryTime()
    }
    
    deinit {
        self.removeNotifications()
    }
    
    //MARK:- IBActions
    
    @IBAction func importCalendarClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func changePasswordClicked(_ sender: UIButton) {
    }
    
    @IBAction func updateLinkExpiryClicked(_ sender: UIButton) {
        guard SocialManager.default.isNetworkReachable(), !self.isFetchingLinkExipryTime else { return }
        self.performSegue(withIdentifier: Segues.segueUpdateLinkExipry, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController =  segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .settings
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .settings
        case is AddShareLinkTimeViewController:
            let addShareLinkTimeViewController = segue.destination as! AddShareLinkTimeViewController
            addShareLinkTimeViewController.delegate = self
        default: break
        }
    }
    
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpiryIcon), name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    @objc func refreshExpiryIcon() {
        self.imageViewExpiryIcon.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
    }
    
    func initializeView() {
    }
}
