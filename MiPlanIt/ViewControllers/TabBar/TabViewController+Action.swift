//
//  TabViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension TabViewController {
    
    func initialiseUIComponents() {
        self.viewRightShadow.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "shadowBorder"))
        self.buttonTabOptions.filter({ return $0.tag == self.selectedOption.rawValue }).first?.isSelected = true
        self.updateValueOfNotificationCount()
        if let user = Session.shared.readUser(), !user.readUserHaveValidPurchase() {
            self.viewBannerAds.config(vc: self)
            self.viewBannerAds.delegate = self
        }
        if !(self.delegate is DashBoardViewController) {
            self.updateAdVisibility()
        }
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateValueOfNotificationCount), name: NSNotification.Name(rawValue: Notifications.userNotifications), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAdSenceView), name: NSNotification.Name(rawValue: Notifications.updateAdSenceView), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.userNotifications), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.updateAdSenceView), object: nil)
    }
    
    @objc func updateAdSenceView() {
        self.updateAdVisibility()
    }
    
    @objc func updateValueOfNotificationCount() {
        guard let count = Session.shared.readUser()?.readValueOfNotificationCount(), count > 0 else { self.labelNotificationCount.isHidden = true; return }
        self.labelNotificationCount.isHidden = false
        self.labelNotificationCount.text = count > 99 ? "99+" : count.cleanValue()
    }
    
    func updateAdVisibility() {
        self.viewBannerAds.isHidden = Session.shared.readUser()?.readUserHaveValidPurchase() ?? false
        self.delegate?.tabViewController(self, updateHeightWithAd: !self.viewBannerAds.isHidden)
    }
    
    func startGradientAnimation() {
        self.dotLoader?.startAnimating()
        self.viewLoadingGradient?.isHidden = false

    }
    
    func stopGradientAnimation() {
        self.dotLoader?.stopAnimating()
        self.viewLoadingGradient?.isHidden = true
    }
    
    func showorHideLoadingView(_ show: Bool) {
        if show {
            self.constraintLoaderHeight.constant = 0
            UIView.animate(withDuration: 1, animations: {
                self.constraintLoaderHeight.constant = 14
            })
        }
        else {
            UIView.animate(withDuration: 1, animations: {
                self.constraintLoaderHeight.constant = 0
            })
        }
    }
    
    func showOrHideNetworkOption() {
        if !self.isNetworkReachable() {
            self.labelCaption.text = "You are Offline. Updates will sync when online"
            self.viewOffline.backgroundColor = .black
            self.showorHideLoadingView(true)
        }
        else {
            self.labelCaption.text = "Back to Online"
            self.viewOffline.backgroundColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showorHideLoadingView(false)
            }
        }
    }
    
    func isNetworkReachable() -> Bool {
        guard let manager = self.networkManager, manager.isReachable else {
            return false
        }
        return true
    }

//    func listenNetwork() {
//        self.networkManager?.listener = { _ in
//            self.showOrHideNetworkOption()
//        }
//        self.networkManager?.startListening( onUpdatePerforming: .)
//    }
    
    func listenNetwork() {
        networkManager?.startListening(onQueue: .main, onUpdatePerforming: { [weak self] status in
            switch status {
            case .reachable(.cellular), .reachable(.ethernetOrWiFi):
                print("Network is reachable")
                // Handle reachable state
            case .notReachable:
                print("Network is not reachable")
                // Handle not reachable state
            case .unknown:
                print("Network status is unknown")
                // Handle unknown state
            }
        })
    }
}
