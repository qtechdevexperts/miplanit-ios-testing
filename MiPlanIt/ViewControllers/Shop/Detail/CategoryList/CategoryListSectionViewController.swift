//
//  CategoryListSectionViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol CategoryListSectionViewControllerDelegate: class {
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, selectedMainCategory: CategoryData?, selectedSubCategory: CategoryData?, userCategory: CategoryData?)
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, add userCategory: CategoryData)
}

class CategoryListSectionViewController: UIViewController {
    
    var categoryItems: [ShopListItemCategoryListOption] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    weak var delegate:  CategoryListSectionViewControllerDelegate?
    
    var selectedMainCategory: CategoryData?
    var selectedSubCategory: CategoryData?
    var selectedUserCategory: CategoryData?
    
    var planItShopItem: PlanItShopItems! {
        didSet {
            if !planItShopItem.readAppShopCategoryId().isEmpty {
                self.selectedUserCategory = CategoryData(id: 0.0, name: planItShopItem.readUserCategoryName(), appId: planItShopItem.readAppShopCategoryId())
            }
            else if planItShopItem.readUserCategoryIdLocalValue() != 0 {
                self.selectedUserCategory = CategoryData(id: planItShopItem.readUserCategoryIdLocalValue(), name: planItShopItem.readUserCategoryName(), appId: nil)
            }
            
            self.selectedSubCategory =  planItShopItem.readMasterSubCategoryLocalIdValue() != 0 ? CategoryData(id: planItShopItem.readMasterSubCategoryLocalIdValue(), name: planItShopItem.readMasterSubCategoryName(), appId: planItShopItem.readAppShopCategoryId()) : nil
            self.selectedMainCategory =  planItShopItem.readMasterCategoryIdLocalValue() != 0 ? CategoryData(id: planItShopItem.readMasterCategoryIdLocalValue(), name: planItShopItem.readMasterCategoryName(), appId: planItShopItem.readAppShopCategoryId()) : nil
        }
    }
    var planItShopListItem: [PlanItShopListItems] = []
    
    
    var shopItemModel: Any! {
        didSet {
            if let planItShopItems = shopItemModel as? PlanItShopItems {
                self.selectedUserCategory = planItShopItems.readUserCategoryIdValue() != 0 ? CategoryData(id: planItShopItems.readUserCategoryIdValue(), name: planItShopItems.readUserCategoryName(), appId: planItShopItems.readAppShopCategoryId()) : nil
                self.selectedSubCategory = planItShopItems.readMasterSubCategoryIdValue() != 0 ? CategoryData(id: planItShopItems.readMasterSubCategoryIdValue(), name: planItShopItems.readMasterSubCategoryName(), appId: planItShopItems.readAppShopCategoryId()) : nil
                self.selectedMainCategory = planItShopItems.readMasterCategoryIdValue() != 0 ? CategoryData(id: planItShopItems.readMasterCategoryIdValue(), name: planItShopItems.readMasterCategoryName(), appId: planItShopItems.readAppShopCategoryId()) : nil
            }
            else if let shopItemDetailModel = shopItemModel as? ShopListItemDetailModel {
                if shopItemDetailModel.userCategoryId != 0 {
                    self.selectedUserCategory = CategoryData(id: shopItemDetailModel.userCategoryId, name: shopItemDetailModel.categoryName, appId: shopItemDetailModel.appCategoryId)
                }
                else if !shopItemDetailModel.appCategoryId.isEmpty {
                    self.selectedUserCategory = CategoryData(id: shopItemDetailModel.userCategoryId, name: shopItemDetailModel.categoryName, appId: shopItemDetailModel.appCategoryId)
                }
                self.selectedSubCategory = shopItemDetailModel.masterSubCategoryId != 0 ? CategoryData(id: shopItemDetailModel.masterSubCategoryId, name: shopItemDetailModel.categoryName, appId: shopItemDetailModel.appCategoryId) : nil
                self.selectedMainCategory = shopItemDetailModel.masterCategoryId != 0 ? CategoryData(id: shopItemDetailModel.masterCategoryId , name: shopItemDetailModel.categoryName, appId: shopItemDetailModel.appCategoryId) : nil
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSortAlphabetically: UIView!
    @IBOutlet weak var buttonSortValue: UIButton!
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonCloseSort(_ sender: UIButton) {
        self.viewSortAlphabetically.isHidden = true
        self.updateListOrder()
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.categoryListSectionViewController(self, selectedMainCategory: self.selectedMainCategory, selectedSubCategory: self.selectedSubCategory, userCategory: self.selectedUserCategory)
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createdCategoryList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AddNewCategoryViewController:
            let addNewCategoryViewController = segue.destination as! AddNewCategoryViewController
            addNewCategoryViewController.delegate = self
        default:
            break
            
        }
    }
    
}
