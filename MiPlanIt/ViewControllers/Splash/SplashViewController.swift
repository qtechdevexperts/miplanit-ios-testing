//
//  ViewController.swift
//  MiPlanIt
//
//  Created by Arun on 13/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
//    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet var buttonType: [UIButton]!
//    @IBOutlet var labelsToAnimate: [UILabel]!
//    @IBOutlet weak var viewGradientLayer: UIView!
    var framePosition = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let encodeString = NSData(data: Data("test".utf8)).aes128Encrypt(withKey: ConfigureKeys.aesKey)?.base64EncodedString()
//
//        let decodeString = String(data: NSData(data: Data(base64Encoded: "cLEsV5fvOYXiwh12el0SJQ==")!).aes128Decrypt(withKey: ConfigureKeys.aesKey), encoding: .utf8)
//        self.requestSpeechAuthorization()
//        self.registerLocalNotificationWithLoggedInUser()
//        self.initializeUIComponents()
        if let user = DatabasePlanItUser().readLoggedInUser() {
            buttonType.forEach { btn in
                btn.isHidden = true
            }
            self.showAllItemsWithoutAnimation(user)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if let view = viewGradientLayer {
//            view.createGradientLayer(colours: [#colorLiteral(red: 53/255.0, green: 173/255.0, blue: 195/255.0, alpha: 1.0), #colorLiteral(red: 137/255.0, green: 213/255.0, blue: 227/255.0, alpha: 1.0), #colorLiteral(red: 240/255.0, green: 182/255.0, blue: 111/255.0, alpha: 1.0)], locations: [0,0.4,1.0], startPOint: CGPoint(x: 0.2, y: 0.0), endPoint: CGPoint(x: 0.8, y: 1.0))
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        guard !self.isAnimationFinished() else { return }
        Session.shared.checkAppVersionChange {
            self.moveLogoAnimation()
        }
        super.viewDidAppear(animated)
    }
}

