//
//  SocialUser.swift
//  SocialLogin
//
//  Created by Arun on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import GoogleSignIn
//import TwitterKit
import MSAL
import AuthenticationServices


public class SocialUser:NSCoder{
    
    public let userId: String
    public var token: String
    public let fullName: String
    public let givenName: String
    public let familyName: String
    public let email: String
    public let phone: String
    public let countryCode: String
    public let profile: String
    public var userType: UserType = .eAWSUser
    public var refreshToken: String = Strings.empty
    public var expiryTokenDate: String = Strings.empty

    required convenience public init(coder aDecoder: NSCoder) {
           let userId = aDecoder.decodeObject(forKey: "userId") as! String
           let token = aDecoder.decodeObject(forKey: "token") as! String
           let fullName = aDecoder.decodeObject(forKey: "fullName") as! String
           let givenName = aDecoder.decodeObject(forKey: "givenName") as! String
           let familyName = aDecoder.decodeObject(forKey: "familyName") as! String
           let email = aDecoder.decodeObject(forKey: "email") as! String
           let phone = aDecoder.decodeObject(forKey: "phone") as! String
           let countryCode = aDecoder.decodeObject(forKey: "countryCode") as! String
           let userType = aDecoder.decodeObject(forKey: "userType") as! UserType
           let refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as! String
           let expiryTokenDate = aDecoder.decodeObject(forKey: "expiryTokenDate") as! String
           let profile = aDecoder.decodeObject(forKey: "profile") as! String
        self.init(userId:userId,token:token,fullName:fullName,givenName:givenName,familyName:familyName,email:email,phone:phone,countryCode:countryCode,userType:userType,refreshToken:refreshToken,expiryTokenDate:expiryTokenDate,profile:profile)
       }
    init(userId: String, token: String, fullName: String,givenName:String,familyName:String,email:String,phone:String,countryCode:String,userType:UserType,refreshToken:String,expiryTokenDate:String,profile:String) {
        self.userId = userId
        self.token = token
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.phone = phone
        self.countryCode = countryCode
        self.userType = userType
        self.refreshToken = refreshToken
        self.expiryTokenDate = expiryTokenDate
        self.profile = profile

    }
    public func encode(with aCoder: NSCoder) {
//          aCoder.encode(userId, forKey: "userId")
//          aCoder.encode(token, forKey: "token")
//          aCoder.encode(fullName, forKey: "fullName")
//          aCoder.encode(givenName, forKey: "givenName")
//          aCoder.encode(familyName, forKey: "familyName")
//          aCoder.encode(email, forKey: "email")
//          aCoder.encode(phone, forKey: "phone")
//          aCoder.encode(countryCode, forKey: "countryCode")
//          aCoder.encode(userType, forKey: "userType")
//          aCoder.encode(refreshToken, forKey: "refreshToken")
//          aCoder.encode(expiryTokenDate, forKey: "expiryTokenDate")
//          aCoder.encode(profile, forKey: "profile")
      }
    init(with user: PlanItSocialUser) {
        self.userId = user.readSocialAccountId()
        self.token = user.readSocialToken()
        self.refreshToken = user.readSocialRefreshToken()
        self.fullName = user.readUserName()
        self.email = user.readUserEmail()
        self.userType = user.socialAccType == 1 ? .eGoogleUser : .eOutlookUser
        self.familyName = Strings.empty
        self.givenName = Strings.empty
        self.phone = Strings.empty
        self.profile = Strings.empty
        self.countryCode = Strings.empty
        self.expiryTokenDate = user.accessTokenExpirationDate?.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) ?? Strings.empty
    }
    
    init(with user: GIDGoogleUser) {
        self.userId = user.userID ?? ""
        self.token = user.accessToken.tokenString
        self.fullName = user.profile?.name ?? ""
        self.givenName = user.profile?.givenName ?? ""
        self.familyName = user.profile?.familyName ?? ""
        self.email = user.profile?.email ?? ""
        self.phone = Strings.empty
        self.profile = Strings.empty
        self.countryCode = Strings.empty
        self.userType = .eGoogleUser
        self.refreshToken = user.refreshToken.tokenString
        self.expiryTokenDate = user.accessToken.expirationDate?.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) ?? ""
    }
    
    init(with user: [String: Any], token: String) {
        self.userType = .eFBUser
        self.userId = user["id"] as? String ?? Strings.empty
        self.email = user["email"] as? String ?? Strings.empty
        self.phone = user["phone"] as? String ?? Strings.empty
        self.token = token
        let firstName = user["first_name"] as? String ?? Strings.empty
        let lastName = user["last_name"] as? String ?? Strings.empty
        self.fullName = firstName + " " + lastName
        self.givenName = user["name"] as? String ?? Strings.empty
        self.familyName = Strings.empty
        self.countryCode = Strings.empty
        self.userType = .eFBUser
        if let picture = user["picture"] as? [String: Any], let data = picture["data"] as? [String: Any] {
            self.profile = data["url"] as? String ?? Strings.empty
        }
        else {
            self.profile = Strings.empty
        }
    }
    
//    init(with session: TWTRSession, email: String) {
//        self.userType = .eTwitterUser
//        self.userId = session.userID
//        self.token = session.authToken
//        self.fullName = session.userName
//        self.givenName = Strings.empty
//        self.familyName = Strings.empty
//        self.email = email
//        self.phone = Strings.empty
//        self.profile = Strings.empty
//        self.countryCode = Strings.empty
//        self.userType = .eTwitterUser
//    }
    
    @available(iOS 13.0, *)
    init(with session: ASAuthorizationAppleIDCredential) {
        self.userId = session.user
        let email = session.email ?? Strings.empty
        var actualEmail = email.contains(Strings.privateEmail) ? Strings.empty : email
        if actualEmail.isEmpty {
            actualEmail = Storage().readConfidentialDataForKey(KeyChainStore.email(session.user)) ?? Strings.empty
        }
        else {
            Storage().saveConfidentialData(actualEmail, forkey: KeyChainStore.email(session.user))
        }
        var name = session.fullName?.givenName ?? Strings.empty
        if name.isEmpty {
            name = Storage().readConfidentialDataForKey(KeyChainStore.name(session.user)) ?? Strings.empty
        }
        else {
            Storage().saveConfidentialData(name, forkey: KeyChainStore.name(session.user))
        }
        self.fullName = name
        self.email = actualEmail
        self.phone = Strings.empty
        self.profile = Strings.empty
        self.countryCode = Strings.empty
        self.userType = .eAppleUser
        self.givenName = Strings.empty
        self.familyName = Strings.empty
        self.token = session.user
    }
    
    init(with user: MSALAccount, result: MSALResult) {
        self.userType = .eOutlookUser
        self.token = result.accessToken
        self.userId = user.identifier ?? Strings.empty
        self.fullName = user.username ?? Strings.empty
        self.givenName = Strings.empty
        self.familyName = Strings.empty
        self.email = Strings.empty
        self.phone = Strings.empty
        self.countryCode = Strings.empty
        self.profile = Strings.empty
        self.expiryTokenDate = result.expiresOn?.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) ?? Strings.empty
    }
    
    init(MSALWebAccess user: [String: Any], name: [String: Any]) {
        self.userType = .eOutlookUser
        self.token = user["access_token"] as? String ?? Strings.empty
        self.refreshToken = user["refresh_token"] as? String ?? Strings.empty
        self.userId = name["id"] as? String ?? Strings.empty
        self.fullName = name["displayName"] as? String ?? Strings.empty
        self.givenName = name["givenName"] as? String ?? Strings.empty
        self.familyName = name["surname"] as? String ?? Strings.empty
        if let mail = name["mail"] as? String, !mail.isEmpty {
            self.email = mail
        }
        else {
            self.email = name["userPrincipalName"] as? String ?? Strings.empty
        }
        self.phone = Strings.empty
        self.countryCode = Strings.empty
        self.profile = Strings.empty
//        let expirySeconds = user["expires_in"] as? String ?? Strings.empty
        if let second = user["expires_in"] as? Int {
            self.expiryTokenDate = Date().adding(seconds: second).stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!)
        }
    }

    init(withAWS aws: AWSResponse, phoneCode: String) {
        self.userType = .eAWSUser
        self.token = aws.token?.accessToken?.tokenString ?? Strings.empty
        self.userId = aws.parameters?["sub"] ?? Strings.empty
        self.fullName = aws.parameters?["name"] ?? Strings.empty
        self.email = aws.parameters?["email"] ?? Strings.empty
        let phoneNumber = aws.parameters?["phone_number"] ?? Strings.empty
        self.phone = phoneNumber.replacingOccurrences(of: phoneCode, with: Strings.empty)
        self.givenName = Strings.empty
        self.familyName = Strings.empty
        self.countryCode = phoneCode
        self.profile = Strings.empty
    }
    
    func readUserName() -> String {
        return self.email.isEmpty ? self.countryCode + self.phone : self.email
    }
}
