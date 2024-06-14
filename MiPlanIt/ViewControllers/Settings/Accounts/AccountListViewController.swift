//
//  AccountListViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class AccountListViewController: UIViewController {
    
    var socialUsers: [SocialUserType] = [] {
        didSet {
            self.imageViewEmptyAccount.isHidden = !self.socialUsers.isEmpty
            self.socialUsers.sort(by: { return $0.type < $1.type })
        }
    }

    var serviceStarted = false {
        didSet {
            if self.serviceStarted { self.startLottieAnimations() }
            else { self.stopLottieAnimations(); }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var imageViewEmptyAccount: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWebserviceToFetchSocialUsers()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNotifications()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
        super.viewWillDisappear(animated)
    }
    
    //MARK: - IBActions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is SettingHelpScreenViewController:
            let settingHelpScreenViewController = segue.destination as! SettingHelpScreenViewController
            settingHelpScreenViewController.fromAccount = true
        case is OutlookWebViewController:
            let outlookWebViewController = segue.destination as! OutlookWebViewController
            outlookWebViewController.delegate = self
        default: break
        }
    }
}
