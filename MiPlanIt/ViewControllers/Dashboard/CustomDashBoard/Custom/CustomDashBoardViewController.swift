//
//  CustomDashBoardViewController.swift
//  MiPlanIt
//
//  Created by fsadmin on 06/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol CustomDashBoardViewControllerDelegate: AnyObject {
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, selectedCustomDashboard: PlanItDashboard?)
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, updateCustomDashboard: PlanItDashboard?)
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, deleteCustomDashboard: PlanItDashboard?)
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, createCustomDashboard: PlanItDashboard?)
}

class CustomDashBoardViewController: DashboardBaseViewController {
    
    var customDashboardView: [CustomDashboardView] = []
    var availableDashboardProfiles: [CustomDashboardProfile] = []
    var profilesImageDownloadCount: Int = 0
    weak var delegate: CustomDashBoardViewControllerDelegate?
    var isAllDashboardServiceCompleted: Bool = false
    var pulseLayers = [CAShapeLayer]()
    let pulsator = Pulsator()
    
    var dashboardSection: DashBoardSection = .today
    @IBOutlet weak var labelUserGreeting: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelitems: UILabel!
    @IBOutlet weak var viewUsersCircle: UIView!
    @IBOutlet weak var viewSubHeading: UIView!
    @IBOutlet weak var imageViewCenterUser: UIImageView!
    @IBOutlet weak var imageViewCountMainCircle: UIImageView!
    @IBOutlet weak var labelitemsCountMain: UILabel!
    @IBOutlet weak var buttonMainUser: UIButton!
    @IBOutlet weak var viewFive: UIView!
    @IBOutlet weak var viewFour: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewFetchingData: UIView?
    @IBOutlet var lottieAnimationView: LottieAnimationView?
    @IBOutlet weak var pulseRoundStartView: UIView?
    
    override func viewDidLoad() {
        self.initialDateRangeSetUp()
        super.viewDidLoad()
        self.updateDashboardProfilesViews()
        self.fetchAllCustomDashBoardUsingNetwork()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewFive.cornurRadius = self.viewFive.frame.size.width / 2
        self.viewFour.cornurRadius = self.viewFour.frame.size.width / 2
        self.viewThree.cornurRadius = self.viewThree.frame.size.width / 2
        self.viewTwo.cornurRadius = self.viewTwo.frame.size.width / 2
        self.imageViewCenterUser.cornurRadius = self.imageViewCenterUser.frame.size.width / 2
        self.pulseRoundStartView?.cornurRadius = self.imageViewCenterUser.cornurRadius
        self.viewUsersCircle.layoutIfNeeded()
        self.pulsator.position = self.viewTwo.layer.position
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNotification()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotification()
        super.viewWillDisappear(animated)
    }
    
    override func dashboardTotalItems(_ items: Int) {
        self.updateMainCount()
    }
    
    override func dashboardHaveExistingData(_ type: DashBoardTitle) {
        self.refreshDashboardDataWithTileSelection(type)
        super.dashboardHaveExistingData(type)
    }
    
    override func dashboardDidFinishDataManipulation(_ type: DashBoardTitle) {
        self.refreshDashboardDataWithTileSelection(type)
        super.dashboardDidFinishDataManipulation(type)
        DispatchQueue.main.async { self.showAllUserDataIfNeeded() }
    }
    
    override func dasboardFindDataForCustomDashboard(_ type: DashBoardTitle) {
        self.updateDashboardProfileViewsWithSpecificType(type)
    }
    
    
    override func startLottieAnimations() {
        super.startLottieAnimations()
        if let viewLoader = self.viewFetchingData, viewLoader.isHidden, self.readServerDataFetchStatus() {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.viewFetchingData?.isHidden = false
            self.lottieAnimationView?.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
        }
    }
    
    override func stopLottieAnimations() {
        super.stopLottieAnimations()
        if let viewLoader = self.viewFetchingData, !viewLoader.isHidden {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.viewFetchingData?.isHidden = true
            if ((self.lottieAnimationView?.isAnimationPlaying) != nil) { self.lottieAnimationView?.stop() }
        }
    }
    
    @IBAction func helpActionClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showDashboardHelp", sender: nil)
    }
    
    @IBAction func myDashboardClicked(_ sender: UIButton) {
        if self.navigationController?.viewControllers.first is Self {
            let storyBoard = UIStoryboard(name: StoryBoards.dashboard, bundle: Bundle.main)
            guard let dashBoardViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.dashboard) as? DashBoardViewController else { return }
            dashBoardViewController.customDashboard = nil
            dashBoardViewController.dashboardEvents = self.dashboardEvents
            dashBoardViewController.currentSearchEventIndex = self.currentSearchEventIndex
            dashBoardViewController.dashboardPurchases = self.dashboardPurchases
            dashBoardViewController.currentSearchPurchaseIndex = self.currentSearchPurchaseIndex
            dashBoardViewController.dashboardGifts = self.dashboardGifts
            dashBoardViewController.currentSearchGiftIndex = self.currentSearchGiftIndex
            dashBoardViewController.dashboardTodos = self.dashboardTodos
            dashBoardViewController.currentSearchToDoIndex = self.currentSearchToDoIndex
            dashBoardViewController.dashboardShopings = self.dashboardShopings
            dashBoardViewController.currentSearchShoppingIndex = self.currentSearchShoppingIndex
            self.navigationController?.setViewControllers([dashBoardViewController], animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.customDashBoardViewControllerDelegate(self, selectedCustomDashboard: nil)
        }
    }
    
    @IBAction func buttonBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonUserListingClicked(_ sender: UIButton) {

    }
    
    @IBAction func buttonAddUsersClicked(_ sender: UIButton) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toCreateDashboard, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is CreateDashboardViewController:
            let createDashboardViewController =  segue.destination as! CreateDashboardViewController
            createDashboardViewController.delegate = self
            createDashboardViewController.customDashboardProfiles = self.availableDashboardProfiles
        case is CustomDashBoardListViewController:
            let customDashBoardListViewController =  segue.destination as! CustomDashBoardListViewController
            customDashBoardListViewController.delegate = self
            customDashBoardListViewController.customDashboardProfile = self.availableDashboardProfiles
            customDashBoardListViewController.dashboardEvents = self.visibleEvents
            customDashBoardListViewController.dashboardPurchase = self.visiblePurchases
            customDashBoardListViewController.dashboardGifts = self.visibleGifts
            customDashBoardListViewController.dashboardTodos = self.visibleTodos
            customDashBoardListViewController.dashboardShopListItems = self.visibleShopings
            customDashBoardListViewController.itemsCount = self.totalItemsCount
            customDashBoardListViewController.activeDashboardSection = self.dashboardSection
        case is DashBoardLongPressPopUpVC:
            let dashBoardLongPressPopUpVC =  segue.destination as! DashBoardLongPressPopUpVC
            dashBoardLongPressPopUpVC.dashboardEvents = self.visibleEvents
            dashBoardLongPressPopUpVC.dashboardTodos = self.visibleTodos
            dashBoardLongPressPopUpVC.dashboardShopListItems = self.visibleShopings
            dashBoardLongPressPopUpVC.dashboardPurchase = self.visiblePurchases
            dashBoardLongPressPopUpVC.dashboardGifts = self.visibleGifts
            dashBoardLongPressPopUpVC.activeSection = self.dashboardSection
            if let profile = sender as? CustomDashboardProfile {
                dashBoardLongPressPopUpVC.selectedDashboardProfile = profile
                dashBoardLongPressPopUpVC.profileImage = profile.planItDashboard.readImage()
            }
        default: break
        }
    }
    
}
