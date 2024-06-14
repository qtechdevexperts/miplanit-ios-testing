//
//  AWSResponse.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import AWSMobileClient

enum Status: String {
    case success = "success"
    case fail = "fail"
}

class AWSResponse {
    
    var status: Status!
    var token: Tokens?
    var parameters: [String : String]?
    
    init(signInResponse: SignInResult){
        if signInResponse.signInState == .signedIn {
            self.status = .success
        }
        else {
            self.status = .fail
        }
    }
    
    init(status: Status) {
        self.status = status
    }
    
    init(token: Tokens, params: [String: String]) {
        self.token = token
        self.parameters = params
        self.status = .success
    }
    
    init(signUpResponse: SignUpResult) {
        if signUpResponse.signUpConfirmationState == .confirmed {
            self.status = .success
        }
        else {
            self.status = .fail
        }
    }
    
    init(forgotPasswordResponse: ForgotPasswordResult) {
        if forgotPasswordResponse.forgotPasswordState == .confirmationCodeSent || forgotPasswordResponse.forgotPasswordState == .done {
            self.status = .success
        }
        else {
            self.status = .fail
        }
    }
    
    init(signUpResult: SignUpResult) {
        if signUpResult.signUpConfirmationState == .confirmed || signUpResult.signUpConfirmationState == .unconfirmed {
            self.status = .success
        }
        else {
            self.status = .fail
        }
    }
}
