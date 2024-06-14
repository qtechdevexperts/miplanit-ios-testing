//
//  LoginViewController+Actions.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 30/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension LoginViewController {
    
    func initializeView() {
        if #available(iOS 13.0, *) {
            self.buttonAppleUser.isHidden = false
        }
        else {
            self.buttonAppleUser.isHidden = true
        }
        self.readDefaultCountryCodeOfPhone()
        
        buttonLogin.setType(type: .primary)
        buttonVerifyUser.setType(type: .primary)
    }
    
    func readDefaultCountryCodeOfPhone() {
        self.buttonCountryCode.setTitle("+\(Storage().readDefaultCountryCodeOnPhone())", for: .normal)
    }
    
    func readSelectedCountryCodeOfPhone() -> String {
        return self.buttonLoginSelection.isSelected ? Strings.empty : (self.buttonCountryCode.titleLabel?.text ?? Strings.empty)
    }
    
    func readUserAccountName() -> String {
        guard let phoneEmail = self.textFieldUsername.text else { return Strings.empty }
        return self.readSelectedCountryCodeOfPhone() + phoneEmail
    }
    
    func showOrHidePhoneCountryCode(_ show: Bool) {
        self.widthConstraintOfCountryCode.constant = show ? 0 : 95
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
    
    func showOrHidePhoneEmailSection(_ show: Bool) {
        self.view.endEditing(true)
        self.textFieldUsername.hideError(false)
        self.textFieldUsername.text = Strings.empty
        self.textFieldUsername.placeholder = show ? Strings.email : Strings.phone
        self.textFieldUsername.keyboardType = show ? .emailAddress : .numberPad
    }
}


