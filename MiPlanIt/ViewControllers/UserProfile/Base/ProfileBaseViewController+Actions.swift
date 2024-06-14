//
//  ProfileBaseViewController+Actions.swift
//  MiPlanIt
//
//  Created by MS Nischal on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import AVFoundation
import PINRemoteImage

extension ProfileBaseViewController {
    
    // MARK: - Initial setup
    func initialiseUserDetails() {
        guard let user = Session.shared.readUser() else { return }
        self.textFieldEmail.isEnabled = user.readValueOfEmail().isEmpty || user.readValueOfEmail() != user.readValueOfUserName()
        self.textFieldPhone.isEnabled = user.readValueOfPhoneNumber().isEmpty || user.readValueOfCountryCode() + user.readValueOfPhoneNumber() != user.readValueOfUserName()
        self.textFieldEmail.textColor = self.textFieldEmail.isEnabled ? UIColor.white : UIColor.white
//        self.textFieldPhone.textColor = self.textFieldPhone.isEnabled ? UIColor.black : UIColor.darkGray
        self.textFieldName.text = user.readValueOfName()
        self.textFieldEmail.text = user.readValueOfEmail()
        self.textFieldPhone.text = user.readValueOfPhoneNumber()
        self.buttonCountryCode.isEnabled = self.textFieldPhone.isEnabled
        self.buttonCountryCode.setTitle(user.readValueOfCountryCode().isEmpty ? "+\(Storage().readDefaultCountryCodeOnPhone())" : user.readValueOfCountryCode(), for: .normal)
        self.buttonUploadProfilePic.isHidden = true
    }
    
    func manageProfilePicCornerRadius() {
        self.imageViewProfilePic.cornurRadius = self.imageViewProfilePic.frame.height / 2
    }
    
    func readSelectedCountryCodeOfPhone() -> String {
        return (self.buttonCountryCode.titleLabel?.text ?? Strings.empty)
    }
    
    func downloadUserProfileImageFromServer() {
        guard let user = Session.shared.readUser() else { return }
        if let imageData = user.readProfileImageData(), !imageData.isEmpty {
            self.imageViewProfilePic.image = UIImage(data: imageData)
        }
        else {
            self.imageViewProfilePic.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
        }
    }
}
