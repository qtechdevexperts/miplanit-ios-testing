//
//  ProfileBaseViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 11/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ProfileBaseViewController {

    func updateProfileToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToUpdateProfile()
        }
        else {
            guard let user = Session.shared.readUser(), let name = self.textFieldName.text, let email = self.textFieldEmail.text, let phone = self.textFieldPhone.text else { return }
            user.updateUserOffline(email: email, phone: phone, name: name)
            self.buttonUpdateProfile.clearButtonTitleForAnimation()
            self.buttonUpdateProfile.showTickAnimation(completion: { _ in
               self.uploadProfileContinueAction()
               if user.readValueOfProfile().isEmpty {
                   self.imageViewProfilePic.pinImageFromURL( URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
               }
            })
        }
    }
    
    func uploadPicToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceForUploadPic()
        }
        else {
            guard let user = Session.shared.readUser(), let image = self.imageViewProfilePic.image, let data = image.jpegData(compressionQuality: 0.5) else { return }
            user.saveProfileImageOffline(data)
            self.buttonUploadProfilePic.clearButtonTitleForAnimation()
            self.buttonUploadProfilePic.showTickAnimation { (result) in
                self.uploadProfilePicAction()
                self.buttonUploadProfilePic.isSelected = false
                self.buttonUploadProfilePic.isHidden = true
            }
        }
    }
}
