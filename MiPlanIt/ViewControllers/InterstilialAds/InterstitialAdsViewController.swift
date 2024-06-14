//
//  InterstitialAdsViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/11/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class InterstitialAdsViewController: UIViewController {
    
    let interstitial = AdMobInterstitial()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.interstitial.delegate = self
        self.interstitial.createAndLoadInterstitial(callback: { result in
            if result {
                self.interstitial.interstitial?.present(fromRootViewController: self)
            }
            else {
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
}

extension InterstitialAdsViewController: AdMobInterstitialDelegate {
    
    func adMobInterstitial(_ adMobInterstitial: AdMobInterstitial, dismissAds: Bool) {
        self.activityIndicator.stopAnimating()
        self.dismiss(animated: false, completion: nil)
    }
}
