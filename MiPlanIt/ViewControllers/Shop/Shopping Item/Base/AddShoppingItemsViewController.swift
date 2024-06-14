//
//  ToDoListBaseViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol AddShoppingItemsViewControllerDelegate: class {
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, deletedShopList: PlanItShopList)
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, addedShopList: PlanItShopList)
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, onUpdate: PlanItShopList)
}


class AddShoppingItemsViewController: UIViewController {
    
    var timerSyncCompleted: Timer?
    var planItShopList: PlanItShopList?
    var currentEditingCellIndex: IndexPath?
    var addToDoAccessoryView: AddToDoAccessoryView?
    var completedQueue: [PlanItShopListItems] = []
    var allShopListItem: [ShopListItemCellModel] = []
    weak var delegate: AddShoppingItemsViewControllerDelegate?
    var shoppingItemListViewController: ShoppingItemListViewController?
    var refreshControl = UIRefreshControl()
    var defaultOpenCompleteSection: Bool = false
    var pullToRefreshDate: String = Session.shared.readUser()?.readUserSettings().readLastFetchUserShopListDataTime() ?? Strings.empty
    
    var selectedSortValue: DropDownItem? {
        didSet {
            if selectedSortValue != nil {
                self.viewSort?.isHidden = false
                self.buttonSortType?.setTitle( "Sort "+(selectedSortValue?.title ?? Strings.empty), for: .normal)
                self.buttonSortType?.isSelected = true
                self.buttonSortArrow?.isSelected = true
            }
            else {
                self.buttonSortType?.isSelected = false
                self.buttonSortArrow?.isSelected = false
            }
        }
    }
    
    var shopListMode: ShopListMode = .default {
        didSet {
            self.buttonAddTodo?.isHidden = shopListMode == .edit
            self.allShopListItem.forEach({ $0.editSelected = false })
            self.tableViewToDoItems?.reloadData()
        }
    }
    
    var incompletedShopListItems: [ShopListItemCellModel] = [] {
        didSet {
            self.updateShopItemCount()
            self.updateVisibilitySelectAndSortView()
            self.updateSectionIncompleteShopListItem()
        }
    }
    
    var sectionedIncompletedShopListItems: [ShopItemListSection] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewListCount: UIView?
    @IBOutlet weak var textViewShopListName: GrowingSpeechTextView!
    @IBOutlet weak var buttonMore: ProcessingButton?
    @IBOutlet weak var buttonList: ProcessingButton!
    @IBOutlet weak var buttonSearch: ProcessingButton!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var tableViewToDoItems: UITableView?
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var stackViewEditAndCompleteShopItem: EditAndCompleteShopItemStackView!
    @IBOutlet weak var viewBGImageContainer: UIView?
    @IBOutlet weak var labelDayPart: UILabel!
    @IBOutlet weak var buttonAddTodo: UIButton?
    @IBOutlet weak var buttonHeaderEdit: UIButton?
    @IBOutlet weak var constraintHeaderTitleXAxis: NSLayoutConstraint?
    @IBOutlet weak var labelHeaderTitle: UILabel!
    @IBOutlet weak var constraintSearchHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonEditCancel: UIButton?
    @IBOutlet weak var viewEditView: UIView?
    @IBOutlet weak var viewSearch: UIView?
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldSearch: NormalSpeechTextField?
    @IBOutlet weak var buttonSelectAll: UIButton?
    @IBOutlet weak var viewSort: UIView?
    @IBOutlet weak var buttonSortType: UIButton?
    @IBOutlet weak var buttonSortArrow: UIButton?
    @IBOutlet weak var labelUndoCompletedCount: UILabel!
    @IBOutlet weak var viewCompletedPopUp: UIView!
    @IBOutlet weak var viewItemSelection: UIView?
    @IBOutlet weak var imageViewNoToDoItem: UIView?
    @IBOutlet weak var labelShopListItemCount: UILabel?
    @IBOutlet weak var buttonLoader: ProcessingButton!
    @IBOutlet weak var labelItemSelectionCount: UILabel!
    @IBOutlet weak var imgSharedBy: UIImageView!
    @IBOutlet weak var containerShopListOptions: UIView!
    @IBOutlet weak var constraintBottomContainer: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonCloseShopList: UIButton!
    @IBOutlet weak var stackViewTop: UIStackView?
    @IBOutlet weak var buttonReorder: ProcessingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUIComponents()
        self.showShopingListInformationIfExist(showCompleteList: self.defaultOpenCompleteSection)
        self.defaultOpenCompleteSection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNotifications()
        IQKeyboardManager.shared.enable = false
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
        IQKeyboardManager.shared.enable = true
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.manageCompletedSectionContainerSize()
        self.shoppingItemListViewController?.shopItemCategoryViewController?.disableItemQuantity()
        super.viewDidAppear(animated)
    }
    
    @IBAction func moreActionClicked(_ sender: UIButton) {
        self.hideCompleteSection()
        self.performSegue(withIdentifier: Segues.segueToMoreList, sender: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismissListView()
    }
    
    @IBAction func addNewToDoItem(_ sender: UIButton) {
        self.hideCompleteSection()
        self.setAddShoppingItemVC()
    }
    
    @IBAction func toggleSearchBox(_ sender: UIButton) {
        self.currentEditingCellIndex = nil
        self.hideCompleteSection()
        self.setOnSearchActive()
    }
    
    @IBAction func categoryReorderButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let shopListCategory = self.sectionedIncompletedShopListItems.filter({ $0.readSectionName() != Strings.shopOtherCategoryName })
        if shopListCategory.count > 1 {
            self.performSegue(withIdentifier: Segues.segueToReorderCategory, sender: shopListCategory)
        }
    }
    
    @IBAction func editCancelClicked(_ sender: UIButton) {
        self.setOnEditModeActive(false)
    }
    
    @IBAction func closeSearchClicked(_ sender: UIButton) {
        self.removeSearch()
    }
    
    
    @IBAction func toggleEditModeSelected(_ sender: UIButton) {
        self.hideCompleteSection()
        self.setOnEditModeActive(true)
    }
    
    @IBAction func selectAllbuttonToggle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.toggleAllCellSelection(by: sender.isSelected)
    }
    
    @IBAction func closeSortClicked(_ sender: UIButton) {
        self.viewSort?.isHidden = true
        self.selectedSortValue = nil
    }
    
    @IBAction func toggleSortOrder(_ sender: UIButton) {
        self.buttonSortArrow?.isSelected = !(self.buttonSortArrow?.isSelected ?? false)
        self.updateIncompletedShopListData()
    }
    
    @IBAction func undoCompletedClicked(_ sender: UIButton) {
        self.undoCompleteShopListItem()
    }
    
    @IBAction func searchValueChanges(_ sender: UITextField) {
        self.searchResultOfShoppingList()
    }
    
    @IBAction func closeShopListClicked(_ sender: UIButton) {
        self.minimizeShopListView()
    }
    
    @IBAction func listButtonClicked(_ sender: UIButton) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MoreActionShopListDropDownController:
            let moreActionShopListDropDownController = segue.destination as! MoreActionShopListDropDownController
            moreActionShopListDropDownController.delegate = self
            moreActionShopListDropDownController.containsShoppingListItems = !self.incompletedShopListItems.isEmpty
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            if let shopList = self.planItShopList {
                var otherUsers = shopList.readAllShopListShareInvitees()
                let categoryOwnerUserId = shopList.createdBy?.readValueOfUserId()
                otherUsers.sort { (user1, user2) -> Bool in
                    user1.readValueOfUserId() == categoryOwnerUserId
                }
                sharedViewController.categoryOwnerId = categoryOwnerUserId
                sharedViewController.selectedInvitees = otherUsers.map({ return CalendarUser($0) })
            }
        case is ShareShoppingViewController:
            let shareShoppingViewController = segue.destination as! ShareShoppingViewController
            shareShoppingViewController.delegate = self
            if let shopList = self.planItShopList {
                shareShoppingViewController.selectedInvitees = shopList.readAllOtherUser()
            }
        case is CreateNewListViewController:
            let createNewListViewController = segue.destination as! CreateNewListViewController
            createNewListViewController.delegate = self
            if let shopList = self.planItShopList {
                createNewListViewController.shop = ShopList(with: shopList)
            }
        case is ShoppingItemDetailViewController:
            let shoppingItemDetailViewController = segue.destination as! ShoppingItemDetailViewController
            if let shopListItemCellModel = sender as? (ShopListItemCellModel, String), let shopItem = shopListItemCellModel.0.shopItem {
                shoppingItemDetailViewController.shopItemDetailModel = ShopListItemDetailModel(shopListItem: shopListItemCellModel.0.planItShopListItem, shopItem: shopItem, quantity: shopListItemCellModel.1)
            }
            else if let shopListItemDetailModel = sender as? ShopListItemDetailModel {
                shoppingItemDetailViewController.shopItemDetailModel = shopListItemDetailModel
            }
            shoppingItemDetailViewController.delegate = self
        case is CategoryListSectionViewController:
            let categoryListSectionViewController = segue.destination as! CategoryListSectionViewController
            categoryListSectionViewController.delegate = self
            if let shopListItemCellModel = sender as? ShopListItemCellModel {
                categoryListSectionViewController.planItShopItem = shopListItemCellModel.shopItem
                categoryListSectionViewController.planItShopListItem = [shopListItemCellModel.planItShopListItem]
            }
        case is ShopListSelectionViewController:
            let shopListSelectionViewController = segue.destination as! ShopListSelectionViewController
            shopListSelectionViewController.delegate = self
            if let shopListItemCellModel = sender as? [ShopListItemCellModel] {
                shopListSelectionViewController.planItShopListItem = shopListItemCellModel.map({$0.planItShopListItem})
                shopListSelectionViewController.currentShopList = self.planItShopList
            }
            if let planItShopListItems = sender as? [PlanItShopListItems] {
                shopListSelectionViewController.planItShopListItem = planItShopListItems
                shopListSelectionViewController.currentShopList = self.planItShopList
            }
        case is ShopListItemViewDetails:
            let shopListItemViewDetails = segue.destination as! ShopListItemViewDetails
            if let shopListItemDetailModel = sender as? ShopListItemDetailModel {
                 shopListItemViewDetails.shopItemDetailModel = shopListItemDetailModel
            }
        case is ShopAttachmentPopUp:
            let shopAttachmentPopUp = segue.destination as! ShopAttachmentPopUp
            if let shopListItemCellModel = sender as? ShopListItemCellModel {
                 shopAttachmentPopUp.shopListItemCellModel = shopListItemCellModel
            }
        case is DueDateViewController:
            let toDoDueDateViewController = segue.destination as! DueDateViewController
            toDoDueDateViewController.delegate = self
        case is ReOrderCategoryViewController:
            let reOrderCategoryViewController = segue.destination as! ReOrderCategoryViewController
            reOrderCategoryViewController.delegate = self
            if let shopListCategory = sender as? [ShopItemListSection] {
                reOrderCategoryViewController.shopListCategory = shopListCategory
            }
        default: break
        }
    }
}
