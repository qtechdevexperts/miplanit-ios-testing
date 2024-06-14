//
//  LoginViewController+Social.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension LoginViewController: SocialManagerDelegate {
    
    func startSocialIconAnimation(_ type: LoginType) {
        self.view.isUserInteractionEnabled = false
        switch type {
        case .facebook:
            self.buttonFBUser.startPulseAnimation()
        case .google:
            self.buttonGoogleUser.startPulseAnimation()
        case .twitter:
            self.buttonTwitterUser.startPulseAnimation()
        case .apple:
            self.buttonAppleUser.startPulseAnimation()
        default: break
        }
    }
    
    func stopSocialIconAnimation(_ type: LoginType) {
        self.view.isUserInteractionEnabled = true
        switch type {
        case .facebook:
            self.buttonFBUser.removeAllLayerAnimations()
        case .google:
            self.buttonGoogleUser.removeAllLayerAnimations()
        case .twitter:
            self.buttonTwitterUser.removeAllLayerAnimations()
        case .apple:
            self.buttonAppleUser.removeAllLayerAnimations()
        default: break
        }
    }
    
    func socialManagerFailedToLogin(_ manager: SocialManager) {
        self.stopSocialIconAnimation(manager.type)
    }
    
    func socialManagerFailedToRestore(_ manager: SocialManager) {
        self.stopSocialIconAnimation(manager.type)
    }
    
    func socialManager(_ manager: SocialManager, loginWithResult result: SocialUser) {
        self.stopSocialIconAnimation(manager.type)
        self.createServiceToRegisterUser(result)
    }
}


extension LoginViewController: CountrySelectionViewControllerDelegate {
    
    func countrySelectionViewController(_ viewController: CountrySelectionViewController, selectedCode: String) {
        self.buttonCountryCode.setTitle("+\(selectedCode)", for: .normal)
    }
}
