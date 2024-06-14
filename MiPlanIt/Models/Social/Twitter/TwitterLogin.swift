//
//  TwitterLogin.swift
//  SocialLogin
//
//  Created by Arun on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
//import TwitterKit

extension SocialManager {
    
//    func twitterApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
//    }
//    
//    func twitterLoginWithConsumerKey(_ consumerKey: String, secretKey: String, result: SocialManagerDelegate?) {
//        self.type = .twitter
//        self.delegate = result
//         TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: secretKey)
//        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
//            guard let twitterSession = session else {
//                self.delegate?.socialManagerFailedToLogin(self)
//                return }
//            self.requestTwitterEmailUsingSession(twitterSession)
//        })
//    }
//    
//    func requestTwitterEmailUsingSession(_ session: TWTRSession)  {
//        TWTRAPIClient.withCurrentUser().requestEmail { email, error in
//            let emailResult = email ?? Strings.empty
//            let socialUser = SocialUser(with: session, email: emailResult)
//            self.delegate?.socialManager(self, loginWithResult: socialUser)
//        }
//    }
}
