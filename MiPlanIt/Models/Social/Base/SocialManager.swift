//
//  SocialManager.swift
//  SocialLogin
//
//  Created by Arun on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import MSAL
import Alamofire

public protocol SocialManagerDelegate: class {
    func socialManager(_ manager: SocialManager, loginWithResult result: SocialUser)
    func socialManagerFailedToLogin(_ manager: SocialManager)
    func socialManagerFailedToRestore(_ manager: SocialManager)
}

public class SocialManager: NSObject {
    
    var isWorkFlowCompleted = false
    var numberOfMinutesToCall: Int = 0
    var type: LoginType = .google
    var socialTokenTimer: Timer?
    weak var delegate: SocialManagerDelegate?
    var publicClient: MSALPublicClientApplication?
    var networkManager = NetworkReachabilityManager()
    var synchronisationType = TokenSynchronisationType.default {
        didSet {
            if self.synchronisationType == .default {
                self.isWorkFlowCompleted = false
            }
            else if self.synchronisationType == .failed || self.synchronisationType == .completed {
                self.isWorkFlowCompleted = self.isSocialAccountsExpired()
            }
        }
    }
    public static let `default` = SocialManager()
    
    public override init() {
        super.init()
        self.listenNetwork()
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        switch type {
        case .google:
            return self.googleApplication(app, open: url, options: options)
        case .facebook:
            return self.facebookApplication(app, open: url, options: options)
        case .twitter:
            //return self.twitterApplication(app, open: url, options: options)
          return false
        case .outlook:
            return self.outlookApplication(app, open: url, options: options)
        case .apple:
            return false
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        switch type {
        case .google: break
        case .facebook:
            self.facebookApplication(application, didFinishLaunchingWithOptions: launchOptions)
        case .twitter: break
        case .outlook: break
        case .apple: break
        }
    }
}
