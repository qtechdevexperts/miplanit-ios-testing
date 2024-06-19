//
//  AccountRegistrationViewController+Action.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AccountRegistrationViewController {
    
    func initializeView() {
        if #available(iOS 13.0, *) {
            self.buttonAppleUser.isHidden = false
        }
        else {
            self.buttonAppleUser.isHidden = true
        }
        self.showDefaultCountryCodeOnPhone()
    }
    
    func showOrHidePhoneCountryCode(_ show: Bool) {
        self.widthConstraintOfCountryCode.constant = show ? 0 : 95
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.viewCountryHolder.alpha = show ? 0 : 1
        }, completion: { _ in })
    }
    
    func showOrHidePhoneEmailSection(_ show: Bool) {
        self.view.endEditing(true)
        self.textFieldMobileOrPhone.hideError(false)
        self.textFieldMobileOrPhone.text = Strings.empty
        self.textFieldMobileOrPhone.placeholder = show ? Strings.email : Strings.phone
        self.textFieldMobileOrPhone.keyboardType = show ? .emailAddress : .numberPad
    }
    
    func readSelectedCountryCodeOfPhone() -> String {
        return self.buttonPhoneSelection.isSelected ? (self.buttonCountryCode.titleLabel?.text ?? Strings.empty) : Strings.empty
    }
    
    func readUserAccountName() -> String {
        guard let phoneEmail = self.textFieldMobileOrPhone.text else { return Strings.empty }
        return self.readSelectedCountryCodeOfPhone() + phoneEmail
    }
    
    func showDefaultCountryCodeOnPhone() {
        self.buttonCountryCode.setTitle("+\(Storage().readDefaultCountryCodeOnPhone())", for: .normal)
    }
    
    func registerUserWithSocial(_ type: UserType) {
        switch type {
        case .eFBUser:
            self.startSocialIconAnimation(.facebook)
            SocialManager.default.loginFacebookFromViewController(self, using: ConfigureKeys.FBClientKey, result: self)
        case .eGoogleUser:
            self.startSocialIconAnimation(.google)
            SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
        case .eTwitterUser:
          return
            //self.startSocialIconAnimation(.twitter)
            //SocialManager.default.twitterLoginWithConsumerKey(ConfigureKeys.twitterConsumerKey, secretKey: ConfigureKeys.twitterSecretKey, result: self)
        case .eAppleUser:
            self.startSocialIconAnimation(.apple)
            SocialManager.default.getAppleProviderID(result: self)
        default:
            break
        }
    }
    
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
}
