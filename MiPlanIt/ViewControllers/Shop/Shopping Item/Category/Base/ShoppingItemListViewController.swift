//
//  ShoppingItemListViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShoppingItemListViewControllerDelegate: class {
    func shoppingItemListViewControllerToggleView(_ shoppingItemListViewController: ShoppingItemListViewController)
    func shoppingItemListViewControllerCloseButtonClick(_ shoppingItemListViewController: ShoppingItemListViewController)
    func shoppingItemListViewControllerCategoryUpdated(_ shoppingItemListViewController: ShoppingItemListViewController)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, editShopListItem shopItem: PlanItShopListItems, withQuantity quantity: String)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addItemOnDetail: ShopListItemDetailModel)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addItem: ShopListItemDetailModel, onSearch flag: Bool)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addNewItem: ShopListItemDetailModel)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addedNewItem: ShopListItemDetailModel)
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addMultiSelectedItem: [ShopListItemDetailModel])
}

class ShoppingItemListViewController: UIViewController {
    
    var currentPlanItShopList: PlanItShopList?
    var shopItemCategoryViewController: ShopItemCategoryViewController?
    var multiSelectedShopItem: [ShopListItemDetailModel] = []
    weak var delegate: ShoppingItemListViewControllerDelegate?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContainerCollectionList: UIView!
    @IBOutlet weak var buttonAddNew: UIButton!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var buttonCategorySort: UIButton!
    @IBOutlet weak var viewSortAlphabetically: UIView!
    @IBOutlet weak var buttonSortValue: UIButton!
    
    var shoppingItems: [ShoppingItemOptionList] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var shoppingListOptionTypeOrder: [ShoppingListOptionType] = [.base] {
        didSet {
            guard let lastType = self.shoppingListOptionTypeOrder.last else { return }
            switch lastType {
            case .base:
                self.readBaseShoppingOptions()
            case .categories, .resentItems, .favoritesList:
                self.readCategoryShoppingOptions()
            default:
                break
            }
        }
    }
    
    lazy var arrayAllShopItemCategory: [PlanItShopMainCategory] = {
        var allCategories = DatabasePlanItShopMasterCategory().readAllShopCategory()
        let allCustomCategory = allCategories.filter({ $0.isCustom })
        if !allCustomCategory.isEmpty {
            allCategories.removeAll { (category) -> Bool in
                allCustomCategory.contains { (customCategory) -> Bool in
                    customCategory == category
                }
            }
            allCategories.append(contentsOf: allCustomCategory)
        }
        if let otherCategoryIndex = allCategories.firstIndex(where: { return $0.masterCategoryId == 1 && !$0.isCustom }) {
            let otherCategoryList = allCategories.remove(at: otherCategoryIndex)
            allCategories.append(otherCategoryList)
        }
        return allCategories
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeData()
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        //self.delegate?.shoppingItemListViewController(self, addMultiSelectedItem: self.multiSelectedShopItem)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.shoppingListOptionTypeOrder.removeLast()
        self.view.endEditing(true)
        self.hideCollectionListItmes()
        self.delegate?.shoppingItemListViewControllerCloseButtonClick(self)
    }
    
    @IBAction func toggleShopListViewClicked(_ sender: UIButton) {
        self.delegate?.shoppingItemListViewControllerToggleView(self)
    }
    
    @IBAction func showSearchVC(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.showSearchShopItemVC, sender: nil)
    }
    
    @IBAction func updateSortActionClicked(_ sender: UIButton) {
        self.buttonSortValue.isSelected = !self.buttonSortValue.isSelected
        self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
    }
    
    @IBAction func toggleSortClicked(_ sender: UIButton) {
        self.viewSortAlphabetically.isHidden = !self.viewSortAlphabetically.isHidden
        if !self.viewSortAlphabetically.isHidden {
            self.updateListOrder(.orderedAscending)
        }
        else {
            self.buttonSortValue.isSelected = false
        }
    }
    
    @IBAction func buttonCloseSort(_ sender: UIButton) {
        self.viewSortAlphabetically.isHidden = true
        self.updateListOrder()
    }
    
    @IBAction func addNewButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.segueAddShopCategory, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AddNewCategoryViewController:
            let addNewCategoryViewController = segue.destination as! AddNewCategoryViewController
            addNewCategoryViewController.delegate = self
            if let category = sender as? PlanItShopMainCategory {
                addNewCategoryViewController.updateShopCategory = category
            }
        case is SearchAllShopItemViewController:
            let searchAllShopItemViewController = segue.destination as! SearchAllShopItemViewController
            searchAllShopItemViewController.delegate = self
            searchAllShopItemViewController.currentPlanItShopList = self.currentPlanItShopList
        case is ShoppingItemDetailViewController:
            let shoppingItemDetailViewController = segue.destination as! ShoppingItemDetailViewController
            if let shopItem = sender as? ShopItem, let planItShop = shopItem.planItShopItem, let shopList = self.currentPlanItShopList {
                shoppingItemDetailViewController.shopItemDetailModel = ShopListItemDetailModel(shopItem: planItShop, quantity: shopItem.quantity, onShopList: shopList)
            }
            shoppingItemDetailViewController.delegate = self
        default:
            break}
    }
    
}
