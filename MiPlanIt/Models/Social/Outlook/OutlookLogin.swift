//
//  OutlookLogin.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MSAL
//import MSGraphClientModels

extension SocialManager {
    
    public func getOutlookAssessRefreshTokens(_ code: String, redirectUri url: String, result: SocialManagerDelegate?) {
        self.type = .outlook
        self.delegate = result
        OutlookService().getMicrosoftLoginToken(code, redirectUrl: url) { (result, error) in
            if let data = result, error == nil, let token = data["access_token"] as? String {
                OutlookService().getMicrosoftUserInfo(token) { (result, error) in
                    if let userInfo = result, error == nil {
                        let socialUser = SocialUser(MSALWebAccess: data, name: userInfo)
                        self.delegate?.socialManager(self, loginWithResult: socialUser)
                    }
                    else {
                        self.delegate?.socialManagerFailedToLogin(self)
                        return
                    }
                }
            }
            else {
                self.delegate?.socialManagerFailedToLogin(self)
                return
            }
        }
    }
    
    public func loginOutlookFromViewController(_ viewController: UIViewController, client: String, scopes: [String], result: SocialManagerDelegate?) {
        self.type = .outlook
        self.delegate = result
        guard let url = URL(string: ServiceData.outlookAuthority), let authority = try? MSALAADAuthority(url: url) else { return }
        let outlookConfiguration = MSALPublicClientApplicationConfig(clientId: client, redirectUri: ServiceData.outlookReDirectURI, authority: authority)
        self.publicClient = try? MSALPublicClientApplication(configuration: outlookConfiguration)
        self.publicClient?.configuration.multipleCloudsSupported = true
        let webParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webParameters)
        parameters.promptType = .selectAccount
        parameters.completionBlockQueue = DispatchQueue.main
        publicClient?.acquireToken(with: parameters, completionBlock: { result, error in
            guard let authResult = result else {
                self.delegate?.socialManagerFailedToLogin(self)
                return }
            let socialUser = SocialUser(with: authResult.account, result: authResult)
            self.delegate?.socialManager(self, loginWithResult: socialUser)
        })
    }
    
    func loadOutlookAccount(usingClient client: String, scopes: [String], inMainQueue: Bool = true, result: SocialManagerDelegate?) {
        self.type = .outlook
        self.delegate = result
        guard let url = URL(string: ServiceData.outlookAuthority), let authority = try? MSALAADAuthority(url: url) else { return }
        let outlookConfiguration = MSALPublicClientApplicationConfig(clientId: client, redirectUri: ServiceData.outlookReDirectURI, authority: authority)
        self.publicClient = try? MSALPublicClientApplication(configuration: outlookConfiguration)
        self.publicClient?.configuration.multipleCloudsSupported = true
        self.loadCurrentAccount(using: self.publicClient, completion: { account in
            guard let currentAccount = account else {
                self.delegate?.socialManagerFailedToRestore(self)
                return
            }
            let parameters = MSALSilentTokenParameters(scopes: scopes, account: currentAccount)
            if inMainQueue { parameters.completionBlockQueue = DispatchQueue.main }
            self.publicClient?.acquireTokenSilent(with: parameters, completionBlock: { result, error in
                guard let authResult = result else {
                    self.delegate?.socialManagerFailedToRestore(self)
                    return }
                let socialUser = SocialUser(with: authResult.account, result: authResult)
                self.delegate?.socialManager(self, loginWithResult: socialUser)
            })
        })
    }
    
    func readOutlookAccounts(usingClient client: String, scopes: [String], inMainQueue: Bool = true, result: @escaping ([SocialUser]?) -> ()) {
        guard let url = URL(string: ServiceData.outlookAuthority), let authority = try? MSALAADAuthority(url: url) else { result(nil); return }
        let outlookConfiguration = MSALPublicClientApplicationConfig(clientId: client, redirectUri: ServiceData.outlookReDirectURI, authority: authority)
        self.publicClient = try? MSALPublicClientApplication(configuration: outlookConfiguration)
        self.publicClient?.configuration.multipleCloudsSupported = true
        self.loadAccountFromDevice(using: self.publicClient, inMainQueue: inMainQueue, completion: { accounts in
            guard let outlookAccounts = accounts, !outlookAccounts.isEmpty else { result(nil); return }
            self.outlookAccount(using: self.publicClient, scopes: scopes, inMainQueue: inMainQueue, atIndex: 0, accounts: outlookAccounts, completion: { socialUsers in
                result(socialUsers)
            })
        })
    }
    
    func outlookAccount(using applicationContext: MSALPublicClientApplication?, scopes: [String], inMainQueue: Bool = true, atIndex: Int, accounts: [MSALAccount], result: [SocialUser] = [], completion: @escaping ([SocialUser]?) -> ()) {
        if atIndex < accounts.count {
            self.fetchOutlookAccount(using: applicationContext, account: accounts[atIndex], scopes: scopes, inMainQueue: inMainQueue, completion: { user in
                var allUsers = result
                if let socialUser = user { allUsers.append(socialUser) }
                self.outlookAccount(using: self.publicClient, scopes: scopes, inMainQueue: inMainQueue, atIndex: atIndex + 1, accounts: accounts, result: allUsers, completion: completion)
            })
        }
        else { completion(result) }
    }
    
    func fetchOutlookAccount(using applicationContext: MSALPublicClientApplication?, account: MSALAccount, scopes: [String], inMainQueue: Bool = true, completion: @escaping (SocialUser?) -> ()) {
        let parameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        if inMainQueue { parameters.completionBlockQueue = DispatchQueue.main }
        applicationContext?.acquireTokenSilent(with: parameters, completionBlock: { result, error in
            guard let authResult = result else {
                completion(nil)
                return }
            let socialUser = SocialUser(with: authResult.account, result: authResult)
            completion(socialUser)
        })
    }
    
    func loadCurrentAccount(using applicationContext: MSALPublicClientApplication?, inMainQueue: Bool = true, completion: @escaping (MSALAccount?) -> ()) {
        guard let applicationContext = applicationContext else { completion(nil); return }
        let msalParameters = MSALParameters()
        if inMainQueue { msalParameters.completionBlockQueue = DispatchQueue.main }
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { currentAccount, previousAccount, error in
            if let _ = error {
                self.loadAccountFromDevice(using: applicationContext, completion: { accounts in
                    completion(accounts?.first)
                })
                
                return
            }
            completion(currentAccount)
        })
    }
    
    func loadAccountFromDevice(using applicationContext: MSALPublicClientApplication?, inMainQueue: Bool = true, completion: @escaping ([MSALAccount]?) -> ()) {
        let msalParameters = MSALAccountEnumerationParameters()
        if inMainQueue { msalParameters.completionBlockQueue = DispatchQueue.main }
        do {
            try applicationContext?.accounts(for: msalParameters)
        } catch { completion(nil); return }
        applicationContext?.accountsFromDevice(for: msalParameters, completionBlock: { accounts, error in
            if let _ = error {
                completion(nil)
                return
            }
            completion(accounts)
        })
    }
    
    func outlookApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
            return false
        }
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
    }
}
