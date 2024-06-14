//
//  TabViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Alamofire
import GradientLoadingBar
import GoogleMobileAds

protocol TabViewControllerDelegate: AnyObject {
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool)
}

class TabViewController: UIViewController {
    
    var selectedOption = TabBarItem.dashBoard
    weak var delegate: TabViewControllerDelegate?
    var networkManager = NetworkReachabilityManager()
    
    @IBOutlet weak var viewBannerAds: BannerAdMob!
    @IBOutlet var buttonTabOptions: [UIButton]!
    @IBOutlet weak var viewRightShadow: UIView!
    @IBOutlet weak var labelNotificationCount: UILabel!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var viewLoadingGradient: UIView?
    @IBOutlet weak var viewOffline: UIView!
    @IBOutlet weak var dotLoader: DotsLoader?
    @IBOutlet weak var constraintLoaderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tabStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotifications()
        self.initialiseUIComponents()
        self.listenNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showOrHideNetworkOption()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let parent = self.parent, parent.isBeingRemoved() {
            self.removeNotifications()
        }
        super.viewDidDisappear(animated)
    }
    
    @IBAction func tabBarOptionTouched(_ sender: UIButton) {
        guard let option = TabBarItem(rawValue: sender.tag) else { return }
        switch option {
        case .dashBoard:
            if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
                self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard, animated: false)
            }
            else  {
                self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard, animated: false)
            }
        case .myCalendar: self.navigationController?.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false)
        case .myTask:
            self.navigationController?.storyboard(StoryBoards.myTask, setRootViewController: StoryBoardIdentifier.todoBase, animated: false)
        case .shoppingList: self.navigationController?.storyboard(StoryBoards.shoppingList, setRootViewController: StoryBoardIdentifier.shoppingList, animated: false)
        case .notification:
            self.navigationController?.storyboard(StoryBoards.requestNotification, setRootViewController: StoryBoardIdentifier.requestNotification, animated: false)
        default:
            break
        }
    }
}


extension TabViewController: BannerAdMobDelegate {
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.viewBannerAds.showORHideMiPlanItSite(false)
    }
    
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.viewBannerAds.showORHideMiPlanItSite(true)
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    func removeBannerButtonClicked(_ bannerAdMob: BannerAdMob) {
        Session.shared.showPricingViewController(forceShow: true)
    }
}
