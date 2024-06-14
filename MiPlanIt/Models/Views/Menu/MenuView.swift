//
//  MenuView.swift
//  MiPlanIt
//
//  Created by Arun on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

var isMenuOpened = false

class MenuView: UIView {
    
    var buttonShadow: UIButton?
    
    @IBOutlet weak var viewScreenContainer: UIView?
    @IBOutlet weak var viewScreenContainerBack1: UIView?
    @IBOutlet weak var viewScreenContainerBack2: UIView?
    @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonMenu: UIButton?
    @IBOutlet weak var imageViewExpiryIcon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addNotifications()
        self.activateMenuTransition()
        self.checkSocialExpiry()
    }
    
    deinit {
        self.removeNotifications()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpiryIcon), name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    @IBAction func showOrHideMenu(_ sender: UIButton) {
        self.showMenu(show: self.menuWidthConstraint.constant == 0)
    }
    
    func checkSocialExpiry() {
        self.imageViewExpiryIcon?.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
    }
    
    @objc func refreshExpiryIcon() {
        self.imageViewExpiryIcon?.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
    }
    
    func showMenu(show: Bool) {
        self.superview?.endEditing(true)
        guard let viewScreenContainer = self.viewScreenContainer, let viewScreenContainerBack1 = self.viewScreenContainerBack1, let viewScreenContainerBack2 = self.viewScreenContainerBack2 else { return }
        self.addOrRemoveShadowButton(show)
        viewScreenContainer.cornurRadius = show ? 10.0 : 0
        viewScreenContainerBack1.cornurRadius = show ? 10.0 : 0
        viewScreenContainerBack2.cornurRadius = show ? 10.0 : 0
        self.menuWidthConstraint.constant = show ? (self.superview?.frame.width ?? 0) / 1.4 : 0
        self.superview?.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.superview?.layoutIfNeeded()
            viewScreenContainer.applyTransform(withScale: show ? 0.7 : 1.0, anchorPoint: CGPoint(x: 0, y: 0.5))
            viewScreenContainerBack1.applyTransform(withScale: show ? 0.7 : 1.0, anchorPoint: CGPoint(x: 0, y: 0.5))
            viewScreenContainerBack2.applyTransform(withScale: show ? 0.7 : 1.0, anchorPoint: CGPoint(x: 0, y: 0.5))
        }, completion: nil)
    }
    
    func activateMenuTransition() {
        guard let viewScreenContainer = self.viewScreenContainer, let viewScreenContainerBack1 = self.viewScreenContainerBack1, let viewScreenContainerBack2 = self.viewScreenContainerBack2, isMenuOpened else { return }
        isMenuOpened = false
        viewScreenContainer.cornurRadius = 10.0
        viewScreenContainerBack1.cornurRadius = 10.0
        viewScreenContainerBack2.cornurRadius = 10.0
        self.menuWidthConstraint.constant = (self.superview?.frame.width ?? 0) / 1.4
        viewScreenContainer.applyTransform(withScale: 0.7, anchorPoint: CGPoint(x: 0, y: 0.5))
        viewScreenContainerBack1.applyTransform(withScale: 0.7, anchorPoint: CGPoint(x: 0, y: 0.5))
        viewScreenContainerBack2.applyTransform(withScale: 0.7, anchorPoint: CGPoint(x: 0, y: 0.5))
        DispatchQueue.main.async {
            self.showMenu(show: false)
        }
    }
    
    func addOrRemoveShadowButton(_ show: Bool) {
        if show && self.buttonShadow == nil {
            guard let mainView = self.viewScreenContainer else { return }
            self.buttonShadow = UIButton(frame: mainView.bounds)
            self.buttonShadow?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.buttonShadow?.addTarget(self, action: #selector(manageButtonInteraction), for: UIControl.Event.touchUpInside)
            mainView.addSubview(self.buttonShadow!)
        }
        else {
            self.buttonShadow?.removeFromSuperview()
            self.buttonShadow = nil
        }
    }
    
    @objc func manageButtonInteraction() {
        self.showMenu(show: false)
    }
}
