//
//  CreateShareLinkViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension CreateShareLinkViewController {
    
    func saveShareLinkToServerUsingNetwork() {
        if SocialManager.default.isNetworkReachable() {
            self.callCreateShareLink()
        }
        else {
            //offline support
            DatabasePlanItShareLink().insertShareLinkOffline(self.shareLinkModel)
            self.buttonSaveShareLink.clearButtonTitleForAnimation()
            self.buttonSaveShareLink.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                self.buttonSaveShareLink.showTickAnimation { (results) in
                    self.delegate?.createShareLinkViewControllerDataUpdated(self)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
