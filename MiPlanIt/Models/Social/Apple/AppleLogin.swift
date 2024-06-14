//
//  AppleLogin.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import AuthenticationServices

extension SocialManager {

    func getAppleProviderID(result: SocialManagerDelegate?) {
        self.delegate = result
        self.type = .apple
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
}


@available(iOS 13.0, *)
extension SocialManager: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let socialUser = SocialUser(with: appleIDCredential)
            
            self.delegate?.socialManager(self, loginWithResult: socialUser)
        }
        else {
            self.delegate?.socialManagerFailedToLogin(self)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.delegate?.socialManagerFailedToLogin(self)
    }
}
