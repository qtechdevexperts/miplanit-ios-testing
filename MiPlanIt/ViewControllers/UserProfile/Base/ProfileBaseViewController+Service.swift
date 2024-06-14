//
//  ProfileBaseViewController+AWS.swift
//  MiPlanIt
//
//  Created by Arun on 27/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ProfileBaseViewController {
    
    func createWebServiceToUpdateProfile() {
        guard let user = Session.shared.readUser(), let name = self.textFieldName.text, let email = self.textFieldEmail.text, let phone = self.textFieldPhone.text else { return }
        self.buttonUpdateProfile.startAnimation()
        UserService().updateUser(user, email: email, phone: phone, name: name, countryCode: self.readSelectedCountryCodeOfPhone(), callback: { result, error in
            if result {
                self.buttonUpdateProfile.clearButtonTitleForAnimation()
                self.buttonUpdateProfile.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                     self.buttonUpdateProfile.showTickAnimation(completion: { _ in
                        self.uploadProfileContinueAction()
                        if user.readValueOfProfile().isEmpty {
                            self.imageViewProfilePic.pinImageFromURL( URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
                        }
                     })
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonUpdateProfile.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceForUploadPic() {
        let fileName = String(Date().millisecondsSince1970) + Extensions.png
        guard let user = Session.shared.readUser(), let image = self.imageViewProfilePic.image, let data = image.jpegData(compressionQuality: 0.5) else { return }
        self.buttonUploadProfilePic.startAnimation()
        UserService().updateUserProfilePic(user, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName, callback: { result, error in
            if result {
                self.buttonUploadProfilePic.clearButtonTitleForAnimation()
                self.buttonUploadProfilePic.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonUploadProfilePic.showTickAnimation { (result) in
                        self.uploadProfilePicAction()
                        self.buttonUploadProfilePic.isSelected = false
                        self.buttonUploadProfilePic.isHidden = true
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonUploadProfilePic.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
