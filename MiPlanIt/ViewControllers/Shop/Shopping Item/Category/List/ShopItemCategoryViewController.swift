//
//  ViewController.swift
//  PageViewControllerWithTabs
//
//  Created by Leela Prasad on 22/03/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

protocol ShopItemCategoryViewControllerDelegate: class {
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, selectedShopItemDetail: ShopListItemDetailModel)
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, multiSelectedShopItem: [ShopListItemDetailModel])
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, selectedShopItem: ShopListItemDetailModel, fromSearch flag: Bool)
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addNew shopItem: ShopListItemDetailModel)
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addedNew shopItem: ShopListItemDetailModel)
    func shopItemCategoryViewControllerOnDetail(_ shopItemCategoryViewController: ShopItemCategoryViewController)
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addNewCetegory category: CategoryData)
}

class ShopItemCategoryViewController: UIViewController {
    
    var currentIndex: Int = 0
    var planItShopCategory: PlanItShopMainCategory? {
        didSet {
            self.updateShopSubCategory()
        }
    }
    var shopListItems: [PlanItShopListItems] = [] {
        didSet {
            let userShopItemIds = shopListItems.filter({ $0.isShopCustomItem }).compactMap({ $0.shopItemId })
            var planItShopItems = DatabasePlanItShopItems().readSpecificUserShopItem(userShopItemIds)
            
            let masterShopItemIds = shopListItems.filter({ !$0.isShopCustomItem }).compactMap({ $0.shopItemId })
            planItShopItems.append(contentsOf: DatabasePlanItShopItems().readSpecificMasterShopItem(masterShopItemIds))
            
            let addShopItems: [ShopItem] = shopListItems.compactMap { (planItShopListItems) in
                if let shopItem = planItShopItems.filter({ item in
                    if item.isUserCreated() {
                        return item.readUserItemIdValue() == planItShopListItems.readShopItemIdValue()
                    }
                    else {
                        return item.readMasterItemIdValue() == planItShopListItems.readShopItemIdValue()
                    }
                }).first {
                    return ShopItem(shopItem, quantity: planItShopListItems.quantity ?? Strings.empty)
                }
                return nil
            }
            self.shopSubCategory = [ShopSubCategoryAndItems(shopItems: addShopItems)]
        }
    }
    
    
    var shopSubCategory: [ShopSubCategoryAndItems] = []
    var pageController: UIPageViewController!
    var currentSelectedShopItem: ShopItem?
    var currentShopList: PlanItShopList?
    var shoppingListOptionType: ShoppingListOptionType?
    weak var delegate: ShopItemCategoryViewControllerDelegate?
    var searchTextValue: String = Strings.empty
    
    @IBOutlet weak var menuBarView: MenuTabsView!
    @IBOutlet weak var viewPageViewContainer: UIView!
    @IBOutlet weak var viewQuantityOption: ShopItemQuantityOptionView!
    @IBOutlet weak var buttonSearchField: UIButton!
    @IBOutlet weak var constraintQuantityBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonSortValue: UIButton!
    @IBOutlet weak var viewSortAlphabetically: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuBarView.dataArray = self.shopSubCategory
        self.menuBarView.isSizeToFitCellsNeeded = true
        self.initializeUI()
        self.presentPageVCOnView()
        
        self.menuBarView.menuDelegate = self
        self.pageController.delegate = self
        self.pageController.dataSource = self
        
        if !self.shopSubCategory.isEmpty {
            self.menuBarView.collView.selectItem(at: IndexPath.init(item: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
            self.pageController.setViewControllers([viewController(At: 0)!], direction: .forward, animated: true, completion: nil)
        }

    }
    
    deinit {
        self.removeNotifications()
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.removeNotifications()
        self.performSegue(withIdentifier: Segues.showSearchShopItemVC, sender: nil)
        //self.enableSearchtextField()
    }
    
    @IBAction func updateSortActionClicked(_ sender: UIButton) {
        self.buttonSortValue.isSelected = !self.buttonSortValue.isSelected
        self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is ShoppingItemDetailViewController:
            let shoppingItemDetailViewController = segue.destination as! ShoppingItemDetailViewController
            if let shopItem = sender as? ShopItem, let planItShop = shopItem.planItShopItem, let shopList = self.currentShopList {
                shoppingItemDetailViewController.shopItemDetailModel = ShopListItemDetailModel(shopItem: planItShop, quantity: shopItem.quantity, onShopList: shopList)
            }
            else if let shopListItemDetailModel = sender as? ShopListItemDetailModel {
                shoppingItemDetailViewController.shopItemDetailModel = shopListItemDetailModel
            }
            shoppingItemDetailViewController.delegate = self
        case is SearchAllShopItemViewController:
            let searchAllShopItemViewController = segue.destination as! SearchAllShopItemViewController
            searchAllShopItemViewController.delegate = self
            searchAllShopItemViewController.currentPlanItShopList = self.currentShopList
            searchAllShopItemViewController.planItShopCategory = self.planItShopCategory
        default:
            break}
    }
}
