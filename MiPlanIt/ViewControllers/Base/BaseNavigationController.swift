//
//  BaseNavigationController.swift
//  MiPlanIt
//
//  Created by Arun on 23/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showSocialAccountExpiryMessage(_:)), name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsExpiry), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsExpiry), object: nil)
    }
    
    @objc func showSocialAccountExpiryDetails(_ notification: Notification) {
        guard let object = notification.object as? String else { return }
        self.topViewController?.showAlert(message: object)
    }
    
    @objc func showSocialAccountExpiryMessage(_ notification: Notification) {
        guard let object = notification.object as? Bool, object, !(self.topViewController is AccountListViewController) else { return }
        self.topViewController?.showAlertWithAction(message: Message.socialAccountsExpired, title: Message.warning, items: [Message.cancel, Message.settings], callback: { index in
            if index == 1 {
                let storyBoard = UIStoryboard(name: StoryBoards.settings, bundle: Bundle.main)
                let accountListViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.accountListViewController)
                self.pushViewController(accountListViewController, animated: true)
            }
        })
    }
}
