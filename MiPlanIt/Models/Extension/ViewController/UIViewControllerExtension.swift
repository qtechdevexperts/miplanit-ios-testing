//
//  UIViewControllerExtension.swift
//  WorkJoe
//
//  Created by MAC6 on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Speech

extension UIViewController {
    
    func readPresentedController() -> UIViewController {
        return self.presentedViewController ?? self
    }
    
    func isBeingRemoved() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let navigationController = appDelegate.window?.rootViewController as? UINavigationController, navigationController.viewControllers.contains(self) else { return true }
        return false
    }
    
    func startTabBarGradientAnimation() {
        if let tabViewController = self.children.filter({ return $0 is TabViewController }).first as? TabViewController {
            tabViewController.startGradientAnimation()
        }
    }
    
    func stopTabBarGradientAnimation() {
        if let tabViewController = self.children.filter({ return $0 is TabViewController }).first as? TabViewController {
            tabViewController.stopGradientAnimation()
        }
    }
    
    //MARK: - Add
    func showInterstitalViewController() {
        guard let user = Session.shared.readUser(), !user.readUserHaveValidPurchase(), Session.shared.timeToShowInterstitialAds() else { return }
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
        guard let interstitialAdsViewController = UIStoryboard(name: StoryBoards.event, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.InterstitialAdsViewController) as? InterstitialAdsViewController else { return }
        interstitialAdsViewController.modalPresentationStyle = .overCurrentContext
        if #available(iOS 13.0, *) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController {
                interstitialAdsViewController.modalPresentationStyle = .overCurrentContext
                rootViewController.present(interstitialAdsViewController, animated: false, completion: nil)
            }
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
            rootViewController.present(interstitialAdsViewController, animated: false, completion: nil)
        }
    }
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    break
                case .restricted:
                    self.showAlert(message: Message.speechRestricted, title: Message.warning, preferredStyle: .alert)
                case .notDetermined:
                    self.showAlert(message: Message.speechNotAuthorized, title: Message.warning, preferredStyle: .alert)
                @unknown default:
                    return
                }
            }
        }
    }
    
    func showTabBarAddOption(_ option: TabBarAddOptions) {
        switch option {
        case .calendar:
            self.performSegue(withIdentifier: Segues.toAddCalendar, sender: self)
        case .event:
            self.performSegue(withIdentifier: Segues.toAddNewEventScreen, sender: self)
        case .task:
            self.performSegue(withIdentifier: Segues.toCustomCategoryToDoListView, sender: self)
        case .purchase:
            self.performSegue(withIdentifier: Segues.toAddPurchase, sender: self)
        case .gift:
            self.performSegue(withIdentifier: Segues.toAddGiftCoupon, sender: self)
        case .shopping:
            self.performSegue(withIdentifier: Segues.toAddShoppingList, sender: self)
        }
    }
    
    //MARK: - Alert
    func showAlert(message: String, title: String = Strings.empty, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    func showAlertWithAction(message: String, title: String = Strings.empty, preferredStyle: UIAlertController.Style = .alert, items: [String], callback: @escaping (_ buttonIndex : NSInteger?) ->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let closure = { (action: UIAlertAction!) -> Void in
            callback(alert.actions.firstIndex(of: action))
        }
        for item in items {
            let defaultAction = UIAlertAction(title: item, style: .default, handler: closure)
            alert.addAction(defaultAction)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showExhaustedAlert() {
        self.showAlert(message: Message.exceedDataStorageLimit, title: Message.outOfStorage)
    }
}
