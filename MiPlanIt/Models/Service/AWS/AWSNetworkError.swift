//
//  NetworkError.swift
//  Swiftee
//
//  Created by ARUN on 09/05/17.
//  Copyright © 2017 Arun. All rights reserved.
//

import Foundation
import AWSMobileClient

class AWSNetworkError {
    
    var code: Int = 0
    
    var message: String = "An unknown error occured"
    var errorType: AWSMobileClientError?
    
    init(error: Any?, code: Int? = nil){
        if let err = error as? AWSMobileClientError {
            self.errorType = err
            switch err {
            case .aliasExists(let message):
                self.message = message
            case .codeDeliveryFailure(let message):
                self.message = message
            case .codeMismatch(let message):
                self.message = message
            case .expiredCode(let message):
                self.message = message
            case .groupExists(let message):
                self.message = message
            case .internalError(let message):
                self.message = message
            case .invalidLambdaResponse(let message):
                self.message = message
            case .invalidOAuthFlow(let message):
                self.message = message
            case .invalidParameter(let message):
                self.message = message
            case .invalidPassword(let message):
                self.message = message
            case .invalidUserPoolConfiguration(let message):
                self.message = message
            case .limitExceeded(let message):
                self.message = message
            case .mfaMethodNotFound(let message):
                self.message = message
            case .notAuthorized(let message):
                self.message = message
            case .passwordResetRequired(let message):
                self.message = message
            case .resourceNotFound(let message):
                self.message = message
            case .scopeDoesNotExist(let message):
                self.message = message
            case .softwareTokenMFANotFound(let message):
                self.message = message
            case .tooManyFailedAttempts(let message):
                self.message = message
            case .tooManyRequests(let message):
                self.message = message
            case .unexpectedLambda(let message):
                self.message = message
            case .userLambdaValidation(let message):
                self.message = message
            case .userNotConfirmed(let message):
                self.code = ConfigureKeys.awsErrorKey
                self.message = message
            case .userNotFound(let message):
                self.message = message
            case .usernameExists(let message):
                self.message = message
            case .unknown(let message):
                self.message = message
            case .notSignedIn(let message):
                self.message = message
            case .identityIdUnavailable(let message):
                self.message = message
            case .guestAccessNotAllowed(let message):
                self.message = message
            case .federationProviderExists(let message):
                self.message = message
            case .cognitoIdentityPoolNotConfigured(let message):
                self.message = message
            case .unableToSignIn(let message):
                self.message = message
            case .invalidState(let message):
                self.message = message
            case .userPoolNotConfigured(let message):
                self.message = message
            case .userCancelledSignIn(let message):
                self.message = message
            case .badRequest(let message):
                self.message = message
            case .expiredRefreshToken(let message):
                self.message = message
            case .errorLoadingPage(let message):
                self.message = message
            case .securityFailed(let message):
                self.message = message
            case .idTokenNotIssued(let message):
                self.message = message
            case .idTokenAndAcceessTokenNotIssued(let message):
                self.message = message
            case .invalidConfiguration(let message):
                self.message = message
            case .deviceNotRemembered(let message):
                self.message = message
            }
        }
        else if let err = error as? NSError {
            self.message = err.localizedDescription
            self.code = err.code
        } else {
            if let desc = error as? String {
                self.message = desc
            }
            if (code != nil){
                self.code = code!
            }
        }
        
    }
}
