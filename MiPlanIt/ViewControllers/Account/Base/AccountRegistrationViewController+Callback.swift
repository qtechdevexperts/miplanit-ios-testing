//
//  AccountRegistrationViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension AccountRegistrationViewController: CountrySelectionViewControllerDelegate {
    
    func countrySelectionViewController(_ viewController: CountrySelectionViewController, selectedCode: String) {
        self.buttonCountryCode.setTitle("+\(selectedCode)", for: .normal)
    }
}

extension AccountRegistrationViewController: SocialManagerDelegate {
    
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
