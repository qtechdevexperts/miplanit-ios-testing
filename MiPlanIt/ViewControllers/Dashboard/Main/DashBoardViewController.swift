//
//  DashBoardViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class DashBoardViewController: DashboardBaseViewController {
    
    var tileViewUpdated: Bool = false
    var tabViewController: TabViewController!
    var activeDashBoardSection: DashBoardSection = .today
    var availableDashboardProfiles: [CustomDashboardProfile] = []
    var overDueToDo: [PlanItTodo] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var viewEventsList: UIView!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var viewCustomDashboards: CustomDashboardSelectionView!
    @IBOutlet weak var viewDashBoardCardList: DashboardItemCardList!
    @IBOutlet weak var collectionViewTile: UICollectionView!
    @IBOutlet weak var buttonDashboardName: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var constraintTabHeight: NSLayoutConstraint?
    
    lazy var customDashboard: PlanItDashboard? = {
        return DatabasePlanItDashboard().readDefaultDashboard()
    }()
    
    lazy var dashboardItems: [DashboardItems] = {
        return [DashboardItems(title: "Events", icon: "eventIcon", type: DashBoardTitle.event, color: [#colorLiteral(red: 0, green: 0.7254901961, blue: 1, alpha: 1), #colorLiteral(red: 0.02352941176, green: 0.007843137255, blue: 0.09803921569, alpha: 1),]),
                DashboardItems(title: "To Do", icon: "todoIconWhite", type: DashBoardTitle.toDo, color: [#colorLiteral(red: 0.3764705882, green: 0.3529411765, blue: 0.768627451, alpha: 1), #colorLiteral(red: 0.0431372549, green: 0.03137254902, blue: 0.1254901961, alpha: 1)]),
                DashboardItems(title: "Shopping", icon: "shoppingIcon", type: DashBoardTitle.shopping, color: [#colorLiteral(red: 1, green: 0.4274509804, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.6078431373, blue: 0.4549019608, alpha: 1)]),
                DashboardItems(title: "Coupons & Gifts", icon: "giftCardIcon", type: DashBoardTitle.giftCard, color: [#colorLiteral(red: 0.5450980392, green: 0.6901960784, blue: 0.168627451, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.9098039216, blue: 0.6549019608, alpha: 1)]),
                DashboardItems(title: "Receipts & Bills", icon: "purchasedashboardIcon", type: DashBoardTitle.purchase, color: [#colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)])]
    }()
    
    override func viewDidLoad() {
        self.initialDateRangeSetUp()
        super.viewDidLoad()
        self.intialiseUIComponents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.tileViewUpdated {
            self.setHorizontalFlowLayout()
            self.collectionViewTile.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tileViewUpdated = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.isHelpShown() {
            self.performSegue(withIdentifier: "toSelectedDashboardHelpScreen", sender: nil)
            Storage().saveBool(flag: true, forkey: UserDefault.selectedDashboardHelp)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewDashBoardCardList.updateCardSize()
    }
    
    override func isHelpShown() -> Bool {
        return Storage().readBool(UserDefault.selectedDashboardHelp) ?? false
    }
    
    override func startLottieAnimations() {
        super.startLottieAnimations()
        if self.readServerDataFetchStatus() {
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.viewFetchingData.isHidden = false
            self.viewEventsList.isHidden = true
            self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
        }
    }
    
    override func stopLottieAnimations() {
        super.stopLottieAnimations()
        if !viewFetchingData.isHidden {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.viewFetchingData.isHidden = true
            self.viewEventsList.isHidden = false
            if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
        }
    }
    
    override func dashboardDidFinishServiceFetch() {
        super.dashboardDidFinishServiceFetch()
        self.viewEventsList.isHidden = false
    }
    
    override func dashboardHaveExistingData(_ type: DashBoardTitle) {
        self.manageUserTileAndAnimation(dataType: type)
        super.dashboardHaveExistingData(type)
    }
    
    override func dashboardWillStartDataManipulation(_ type: DashBoardTitle) {
        self.startLoadingIndicatorForCards(type)
    }
    
    override func dashboardDidEndDataManipulation(_ type: DashBoardTitle) {
        self.stopLoadingIndicatorForCards(type)
        if type == .toDo { self.calculateOverDueToDo() }
    }
    
    override func dashboardDidFinishDataManipulation(_ type: DashBoardTitle) {
        self.updateSpecificTileData(dataType: type)
        super.dashboardDidFinishDataManipulation(type)
    }
    
    override func dasboardFindDataForCustomDashboard(_ type: DashBoardTitle) {
        self.updateDashboardProfileViewsWithSpecificType(type)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .dashBoard
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .dashBoard
            tabViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is DashBoardListMainViewController:
            let dashBoardListMainViewController = segue.destination as! DashBoardListMainViewController
            dashBoardListMainViewController.delegate = self
            if let (dashboardItem, selectedIndex) = sender as? ([DashboardItems], Int) {
                dashBoardListMainViewController.dashboardItems = dashboardItem
                dashBoardListMainViewController.selectedItemIndex = selectedIndex
                dashBoardListMainViewController.dashBoardSection = self.activeDashBoardSection
                dashBoardListMainViewController.isCustomDashboard = self.isCustomDashBord()
                dashBoardListMainViewController.overDueToDo = self.overDueToDo
            }
        case is CustomDashBoardViewController:
            let customDashBoardViewController = segue.destination as! CustomDashBoardViewController
            customDashBoardViewController.delegate = self
            customDashBoardViewController.dashboardEvents = self.dashboardEvents
            customDashBoardViewController.currentSearchEventIndex = self.currentSearchEventIndex
            customDashBoardViewController.dashboardTodos = self.dashboardTodos
            customDashBoardViewController.currentSearchToDoIndex = self.currentSearchToDoIndex
            customDashBoardViewController.dashboardGifts = self.dashboardGifts
            customDashBoardViewController.currentSearchGiftIndex = self.currentSearchGiftIndex
            customDashBoardViewController.dashboardPurchases = self.dashboardPurchases
            customDashBoardViewController.currentSearchPurchaseIndex = self.currentSearchPurchaseIndex
            customDashBoardViewController.dashboardShopings = self.dashboardShopings
            customDashBoardViewController.currentSearchShoppingIndex = self.currentSearchShoppingIndex
            customDashBoardViewController.dashboardSection = self.activeDashBoardSection
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
            customDashBoardListViewController.editable = true
            customDashBoardListViewController.activeDashboardSection = self.activeDashBoardSection
        case is CreateDashboardViewController:
            let createDashboardViewController = segue.destination as? CreateDashboardViewController
            createDashboardViewController?.delegate = self
        case is DashboardDropDownViewController:
            let dashboardDropDownViewController = segue.destination as? DashboardDropDownViewController
            dashboardDropDownViewController?.delegate = self
        case is MasterSearchViewController:
            let masterSearchViewController = segue.destination as! MasterSearchViewController
            masterSearchViewController.dashboardPurchases = self.dashboardPurchases
            masterSearchViewController.currentSearchPurchaseIndex = self.currentSearchPurchaseIndex
            masterSearchViewController.dashboardShopings = self.dashboardShopings
            masterSearchViewController.currentSearchShoppingIndex = self.currentSearchShoppingIndex
            masterSearchViewController.dashboardGifts = self.dashboardGifts
            masterSearchViewController.currentSearchGiftIndex = self.currentSearchGiftIndex
            masterSearchViewController.dashboardEvents = self.dashboardEvents
            masterSearchViewController.currentSearchEventIndex = self.currentSearchEventIndex
            masterSearchViewController.dashboardTodos = self.dashboardTodos
            masterSearchViewController.currentSearchToDoIndex = self.currentSearchToDoIndex
            masterSearchViewController.activeCustomDashboard = self.customDashboard
        case is SelectedDashboardHelpScreen:
            let selectedDashboardHelpScreen = segue.destination as? SelectedDashboardHelpScreen
            selectedDashboardHelpScreen?.delegate = self
        default: break
        }
    }
}
