//
//  AWSRequest.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import AWSMobileClient

class AWSRequest {
    
    func getTokenAndAttributes(callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()) {
        AWSMobileClient.default().getTokens { (tokenResult, error) in
            DispatchQueue.main.async {
                if let result = tokenResult {
                    self.getAWSUserAttributesUsingToken(result, callback: callback)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func signInWithAWS(username: String, password: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().currentUserState = .signedOut
        AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
            DispatchQueue.main.async {
                if let response = signInResult, response.signInState == .signedIn {
                    self.getTokenAndAttributes { (awsResponse, error) in
                        callback(awsResponse, nil)
                    }
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func signUpWithAWS(username: String, password: String, attributes: [String: String], callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().signUp(username: username, password: password, userAttributes: attributes) { (signUpResult, error) in
            DispatchQueue.main.async {
                if let result = signUpResult {
                    callback(AWSResponse(signUpResult: result), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func forgotPasswordWithAWS(username: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().forgotPassword(username: username) { (forgotPasswordResult, error) in
            DispatchQueue.main.async {
                if let result = forgotPasswordResult {
                    callback(AWSResponse(forgotPasswordResponse: result), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func confirmForgotPasswordWithAWS(username: String, newPassword: String, confirmationCode: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode) { (forgotPasswordResult, error) in
            DispatchQueue.main.async {
                if let result = forgotPasswordResult {
                    callback(AWSResponse(forgotPasswordResponse: result), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func changePasswordWithAWS(currentPassword: String, proposedPassword: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().changePassword(currentPassword: currentPassword, proposedPassword: proposedPassword) { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    callback(AWSResponse(status: .success), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func confirmSignUpWithAWS(username: String, password: String, confirmationCode: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()){
        AWSMobileClient.default().confirmSignUp(username: username, confirmationCode: confirmationCode) { (signUpResult, error) in
            DispatchQueue.main.async {
                if let result = signUpResult, result.signUpConfirmationState == .confirmed {
                    self.signInWithAWS(username: username, password: password) { (awsResponse, error) in
                        callback(awsResponse, nil)
                    }
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    static func isSignedInAWS() -> Bool {
        return AWSMobileClient.default().isSignedIn
    }
    
    func signOutAWS(callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()) {
        AWSMobileClient.default().signOut { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    callback(AWSResponse(status: .success), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func getAWSUserAttributesUsingToken(_ token: Tokens, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()) {
        AWSMobileClient.default().getUserAttributes { (attributes, error) in
            DispatchQueue.main.async {
                if let result = attributes {
                    callback(AWSResponse(token: token, params: result), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
    
    func resendSignUpCode(username: String, callback:  @escaping (AWSResponse?, AWSNetworkError?) ->()) {
        AWSMobileClient.default().resendSignUpCode(username: username) { (signUpResult, error) in
            DispatchQueue.main.async {
                if let result = signUpResult {
                    callback(AWSResponse(signUpResult: result), nil)
                }
                else if let error = error {
                    callback(nil, AWSNetworkError(error: error))
                }
            }
        }
    }
}

