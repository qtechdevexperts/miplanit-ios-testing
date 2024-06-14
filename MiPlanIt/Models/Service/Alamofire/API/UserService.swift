//
//  UserService.swift
//  MiPlanIt
//
//  Created by Arun on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserService {
    
    func createParameterFromUser(_ user: SocialUser) -> [String: Any] {
        return [ "username": user.readUserName(), "name": user.fullName, "socialUnique": user.token, "socialLogin": String(user.userType.rawValue), "phone": user.phone, "email": user.email, "telCountryCode": user.countryCode, "country": NSLocale.current.regionCode ?? Strings.empty, "lang": NSLocale.current.languageCode ?? Strings.empty, "utcOffset":  TimeZone.current.offsetFromUTC(), "deviceId": Session.shared.readDeviceId(), "socialId": user.userId]
    }
    
    func login(user: SocialUser, callback: @escaping (PlanItUser?, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.loginUser(self.createParameterFromUser(user), callback: { response, error in
            if let result = response {
                let planItUser = DatabasePlanItUser().insertUser(result, using: user)
                callback(planItUser, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func register(user: SocialUser, callback: @escaping (PlanItUser?, Bool, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.registerUser(self.createParameterFromUser(user), callback: { response, newUser, error in
            if let result = response {
                let planItUser = DatabasePlanItUser().insertUser(result, using: user)
                callback(planItUser, newUser, nil)
            }
            else {
                callback(nil, false, error)
            }
        })
    }
    
    func updateUser(_ user: PlanItUser, email: String, phone: String, name: String, countryCode: String, callback: @escaping (Bool, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.updateProfile(["userId": user.readValueOfUserId(), "name": name, "phone": phone, "telCountryCode": countryCode, "email": email], callback: { response, error in
            if let _ = response {
                user.updateUser(email: email, phone: phone, name: name)
                callback(true, nil)
            }
            else {
                callback(false, error)
            }
        })
    }
    
    func updateUserProfilePic(_ user: PlanItUser, file: String, name: String, callback: @escaping (Bool, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.uploadProfilePic(["userId": user.readValueOfUserId(), "fileName": name, "fileData": file], callback: { response, error in
            if let result = response, let image = result["profileImage"] as? String {
                user.saveProfileImage(image)
                callback(true, nil)
            }
            else {
                callback(false, error)
            }
        })
    }
    
    func checkUserAlreadyExist(_ userName: String, callback: @escaping (Bool?, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.checkUserExist(["userName": userName], callback: { status, error in
            if let result = status {
                callback(result, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func uploadAttachement(_ attachement: UserAttachment, callback: @escaping (UserAttachment?, String?) -> ()) {
        let userCommand = UserCommand()
        userCommand.uploadAttachment(["activityType": attachement.type.rawValue, "attachmentName": attachement.file, "fileData": attachement.data.base64EncodedString(options: .lineLength64Characters), "createdAt": attachement.createdDate.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!), "createdBy": attachement.itemOwnerId ?? Session.shared.readUserId()], callback: { response, error in
            if let result = response, let attachmentId = result["attachmentId"] as? Double {
                attachement.identifier = attachmentId.cleanValue()
                if let attachmentUrl = result["attachmentUrl"] as? String {
                    attachement.data.saveDataWithURL(attachmentUrl)
                }
                callback(attachement, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func checkUserStorageExhausted() {
        guard let user = Session.shared.readUser() else { return }
        let serviceCommand = UserCommand()
        serviceCommand.getUserDataStorage(["userId": user.readValueOfUserId()], callback: { response, error in
            if let data = response {
                DatabasePlanItDataStorage().insertUserStorageData(data) { (status) in
                    Session.shared.readUser()?.saveExhaustedFlag(status)
                }
            }
        })
    }
    
    func getUserDataStorage(_ user: PlanItUser, callback: @escaping (PlanItDataStorage?, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.getUserDataStorage(["userId": user.readValueOfUserId()], callback: { response, error in
            if let data = response {
                let dataStorage = DatabasePlanItDataStorage().insertUserStorageData(data)
                Session.shared.readUser()?.saveExhaustedFlag(dataStorage.totalSpace <= dataStorage.usedSpace)
                callback(dataStorage, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func getRegisteredContacts(_ phones: [CalendarUser], emails: [CalendarUser], callback: @escaping ([PlanItContacts]?, String?) -> ()) {
        let serviceCommand = UserCommand()
        let emailKeys = emails.map({ return $0.email })
        let phoneKeys = phones.compactMap({ return !$0.phone.isEmpty ? $0.countryCode+$0.phone : nil })
        serviceCommand.getRegisteredContacts(["phone": phoneKeys, "email": emailKeys]) { (response, error) in
            DatabasePlanItContacts().insertPlanItContacts(response, phones: phones, emails: emails, callback: { contacts in
                callback(contacts, error)
            })
        }
    }
    
    func getLinkExpiryTime(_ user: PlanItUser, callback: @escaping (Double?, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.getLinkExpiryTime(["userId": user.readValueOfUserId()]) { (response, error) in
            if let data = response, let time = data["linkExpiryDays"] as? Double {
                user.saveLinkExpiryTime(time)
                callback(time, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
    
    func saveLinkExpiryTime(_ user: PlanItUser, linkExpiryTime: Double, callback: @escaping (Double?, String?) -> ()) {
        let serviceCommand = UserCommand()
        serviceCommand.saveLinkExpiryTime(["userId": user.readValueOfUserId(), "linkExpiryDays": linkExpiryTime]) { (response, error) in
            if let status = response, status {
                user.saveLinkExpiryTime(linkExpiryTime)
                callback(linkExpiryTime, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
}

class UserCommand: WSManager {
    
    func loginUser(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.login, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func registerUser(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, Bool, String?) -> ()) {
        self.post(endPoint: ServiceData.registration, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, result.error != Message.userAlreadyExist, nil)
                }
                else {
                    callback(nil, result.error != Message.userAlreadyExist, result.error)
                }
            }
            else {
                callback(nil, false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func updateProfile(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.updateProfile, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func uploadProfilePic(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.uploadProfilePic, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func checkUserExist(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.userExist, params: params, callback: { response, error in
            if let result = response {
                if result.success {
                    callback(true, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func uploadAttachment(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.attachmentAdd, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getUserDataStorage(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.userDataSize, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getRegisteredContacts(_ params: [String: Any]?, callback: @escaping ([[String: Any]]?, String?) -> ()) {
        self.post(endPoint: ServiceData.registeredContacts, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]] {
                    callback(data, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getLinkExpiryTime(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.linkUserExpiry, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func saveLinkExpiryTime(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.addlinkUserExpiry, params: params, callback: { response, error in
            if let result = response {
                if result.success {
                    callback(true, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
}
