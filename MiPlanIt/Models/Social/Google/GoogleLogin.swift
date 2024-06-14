//
//  GoogleLogin.swift
//  SocialLogin
//
//  Created by Arun on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import GoogleSignIn

extension SocialManager {
    
    public func loginGoogleFromViewController(_ viewController: UIViewController, client: String, scopes: [String]? = nil, result: SocialManagerDelegate?) {
        self.type = .google
        self.delegate = result
        GIDSignIn.sharedInstance().clientID = client
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = viewController
        if let bScopes = scopes {
            GIDSignIn.sharedInstance().scopes = bScopes
        }
        GIDSignIn.sharedInstance().signIn()
    }
    
    func googleApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func googleRefreshAccounts(client: String, result: @escaping ([SocialUser]?) -> ()) {
        guard let currentUser = GIDSignIn.sharedInstance()?.currentUser else {
            self.restoreGoogleSignIn(client: client, result: result)
            return }
        self.refreshAccountWithResult(currentUser, result: result)
    }
    
    func refreshAccountWithResult(_ currentUser: GIDGoogleUser, result: @escaping ([SocialUser]?) -> ()) {
        currentUser.authentication.refreshTokens { auth, error in
            guard error == nil else { result(nil); return }
            let socialUser = SocialUser(with: currentUser)
            result([socialUser])
        }
    }
    
    func restoreGoogleSignIn(client: String, scopes: [String]? = nil, result: @escaping ([SocialUser]?) -> ()) {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else { result(nil); return }
        GIDSignIn.sharedInstance.clientID = client
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
}

extension SocialManager: GIDSignInDelegate {
    //cancel popup
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let googleUser = user else {
            self.delegate?.socialManagerFailedToLogin(self)
            return }
        let socialUser = SocialUser(with: googleUser)
        self.sendGoogleAccountsToServer([socialUser])
        self.delegate?.socialManager(self, loginWithResult: socialUser)
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.sendGoogleAccountsToServerFailed()
    }
}
