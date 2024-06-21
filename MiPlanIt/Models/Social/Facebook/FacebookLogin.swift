//
//  FaceBookLogin.swift
//  SocialLogin
//
//  Created by Arun on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension SocialManager {
    
    func facebookApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func facebookApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    public func loginFacebookFromViewController(_ viewController: UIViewController, using appId: String, result: SocialManagerDelegate?) {
        self.type = .facebook
//        Settings.appID = appId

      //let settings = Settings.init()
      //settings.appID = appId
        self.delegate = result
        let loginManager = LoginManager()
        //loginManager.loginBehavior = .browser

        loginManager.logIn(permissions: ["email"], from: viewController, handler: { result, error in
            guard let out = result, !out.isCancelled else {
                self.delegate?.socialManagerFailedToLogin(self)
                return }
            self.requestUserBasicDetails(out)
        })
    }
    
    func requestUserBasicDetails(_ result: LoginManagerLoginResult) {
        guard let token = result.token?.tokenString else { return }
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start{ (connection, result, error) -> Void in
            guard let fbUser = result as? [String: Any] else { return }
            let socialUser = SocialUser(with: fbUser, token: token)
            self.delegate?.socialManager(self, loginWithResult: socialUser)
        }
    }
}
