//
//  OfflineTriggerProfile.swift
//  MiPlanIt
//
//  Created by Febin Paul on 11/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func saveProfileToServer(_ finished: @escaping () -> ()) {
        if let currentUser = DatabasePlanItUser().readCurrentUser(), let user = Session.shared.readUser(), currentUser.isPending {
            UserService().updateUser(user, email: currentUser.readValueOfEmail(), phone: currentUser.readValueOfPhoneNumber(), name: currentUser.readValueOfName(), countryCode: currentUser.readValueOfCountryCode()) { (_, _) in
                self.saveProfilePicToServer(finished)
            }
        }
        else {
            self.saveProfilePicToServer(finished)
        }
    }
    
    func saveProfilePicToServer(_ finished: @escaping () -> ()) {
        if let currentUser = DatabasePlanItUser().readCurrentUser(), let user = Session.shared.readUser(), let data = currentUser.profileImageData, !data.isEmpty {
            let fileName = String(Date().millisecondsSince1970) + Extensions.png
            UserService().updateUserProfilePic(user, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName) { (_, _) in
                finished()
            }
        }
        else {
            finished()
        }
    }
}
