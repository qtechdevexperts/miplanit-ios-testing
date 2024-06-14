//
//  CreateShareLinkViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension CreateShareLinkViewController {
    
    func callCreateShareLink() {
        self.buttonSaveShareLink.startAnimation()
        CalendarService().addShareLink(shareLink: self.shareLinkModel) { (status, error) in
            if let result = status, result {
                self.buttonSaveShareLink.clearButtonTitleForAnimation()
                self.buttonSaveShareLink.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSaveShareLink.showTickAnimation { (results) in
                        self.delegate?.createShareLinkViewControllerDataUpdated(self)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else {
                self.buttonSaveShareLink.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
}
