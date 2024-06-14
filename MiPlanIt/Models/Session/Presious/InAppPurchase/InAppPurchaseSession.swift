//
//  InAppPurchaseSession.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func checkForValidPurchase(callback: @escaping (Bool)->()) {
        guard let user = Session.shared.readUser() else { callback(false); return }
        InAppPurchaseService().verifySubscriptionStatus(user: user) {
            callback(true)
        }
    }
    
    func showPricingViewController(forceShow: Bool = false) {
        if !forceShow && self.readInitialPricingPopUpShown() { return }
        guard let pricingViewController = UIStoryboard(name: StoryBoards.pricing, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.pricingViewController) as? PricingViewController else { return }
        pricingViewController.isAlreadySubscribed =  (Session.shared.readUser()?.self.isValidPurchase) != nil
        if #available(iOS 13.0, *) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController {
                pricingViewController.modalPresentationStyle = .overCurrentContext
                rootViewController.present(pricingViewController, animated: true, completion: nil)
            }
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
            pricingViewController.modalPresentationStyle = .overCurrentContext
            rootViewController.present(pricingViewController, animated: true, completion: nil)
        }
    }
    func isPricingViewController() -> Bool {
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presentedViewController = topController.presentedViewController, presentedViewController is PricingViewController {
                return true
            }
        }
        return false
    }
}
