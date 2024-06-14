//
//  BannerAdMob.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/11/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol BannerAdMobDelegate: GADBannerViewDelegate {
    func removeBannerButtonClicked(_ bannerAdMob: BannerAdMob)
}

class BannerAdMob: UIView {

    let kCONTENT_XIB_NAME = "BannerAdMob"
    weak var delegate: BannerAdMobDelegate?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var addMiPlanItBanner: UIImageView!
    @IBOutlet weak var buttonMiPlanIt: UIButton!
    @IBOutlet weak var viewBannerAdMob: GADBannerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func config(vc: BannerAdMobDelegate) {
        self.viewBannerAdMob.adUnitID = ConfigureKeys.adBannerUnitID
        self.viewBannerAdMob.rootViewController = vc as? UIViewController
        self.viewBannerAdMob.load(GADRequest())
        self.viewBannerAdMob.delegate = vc
        self.delegate = vc
    }
    
    func showORHideMiPlanItSite(_ show: Bool) {
        self.buttonMiPlanIt.isHidden = !show
        self.addMiPlanItBanner.isHidden = !show
    }
    
    @IBAction func removeAdsClicked(_ sender: UIButton) {
        isMenu = true
        self.delegate?.removeBannerButtonClicked(self)
    }
    
    @IBAction func openMiPlanItSite(_ sender: Any) {
        if let url = URL(string: Strings.miplanitSite), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, completionHandler: { _ in })
        }
    }
    
}
