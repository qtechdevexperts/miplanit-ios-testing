//
//  AdMobProtocol.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/11/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol AdMobInterstitialDelegate: class {
    func adMobInterstitial(_ adMobInterstitial: AdMobInterstitial, dismissAds: Bool)
}

class AdMobInterstitial: NSObject {
    
    var interstitial: GADInterstitialAd?
    weak var delegate: AdMobInterstitialDelegate?
    
    override init() {
        super.init()
    }
        
    func createAndLoadInterstitial( callback: @escaping (Bool)->()) {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: ConfigureKeys.adIntersticialUnitID, request: request, completionHandler: { [self] ad, error in
            if let _ = error { callback(false); return }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            callback(true)
        })
    }
}

extension AdMobInterstitial: GADFullScreenContentDelegate {
    
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad presented full screen content.
//      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did present full screen content.")
//      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Session.shared.saveLastShownInterstitialAds()
        self.delegate?.adMobInterstitial(self, dismissAds: true)
      }
}
