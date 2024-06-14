//
//  ToDoListBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import AudioToolbox


extension AddShoppingItemsViewController {
    
    func initializeUIComponents() {
        self.addToDoAccessoryView = AddToDoAccessoryView(frame: CGRect(x: 0, y: 0, width: 10, height: 64))
        self.addToDoAccessoryView?.backgroundColor = UIColor.clear
        self.labelDayPart.text = "Good " + Date().getDayPart()
        self.textFieldSearch?.attributedPlaceholder = NSAttributedString(string: "Search Shopping Items",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        self.textFieldSearch?.delegate = self
        self.textFieldSearch?.normalSpeechDelegate = self
        self.stackViewEditAndCompleteShopItem.delegate = self
        self.constraintHeaderTitleXAxis?.isActive = false
        self.addSwipeGesture()
        self.initialRefreshControl()
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.stackViewEditAndCompleteShopItem.addGestureRecognizer(swipeDown)
        self.loadInterstilialAds()
    }
    
    func loadInterstilialAds() {
//        self.showInterstitalViewController()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.stackViewEditAndCompleteShopItem.toggleCompletedShopList(show: false)
    }
    
    func hideCompleteSection() {
        if !self.stackViewEditAndCompleteShopItem.tableViewShopListItems.isHidden {
            self.stackViewEditAndCompleteShopItem.toggleCompletedShopList(show: false)
        }
    }
    
    func initialRefreshControl() {
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewToDoItems?.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        self.createWebServiceMasterDataInsidePullToRefresh { [weak self] (serviceDetection) in
            guard let self = self else {return}
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
                if serviceDetection.isContainedSpecificServiceData(.shop) || self.pullToRefreshDate != (Session.shared.readUser()?.readUserSettings().readLastFetchUserShopListDataTime() ?? Strings.empty) {
                    self.pullToRefreshDate = Session.shared.readUser()?.readUserSettings().readLastFetchUserShopListDataTime() ?? Strings.empty
                    self.showShopingListInformationIfExist()
                    guard let shopList = self.planItShopList else { return }
                    self.delegate?.addShoppingItemsViewController(self, onUpdate: shopList)
                }
            }
        }
    }
    
    func setVisibilityCategoryReorder(forceHide: Bool = false) {
        self.buttonReorder.isHidden = forceHide || self.sectionedIncompletedShopListItems.filter({ $0.readSectionName() != Strings.shopOtherCategoryName }).count < 2 || self.shopListMode == .edit
    }
    
    func updateSectionIncompleteShopListItem() {
        let groupItems = Dictionary(grouping: self.incompletedShopListItems, by: { shopListItem -> String in
            if (shopListItem.shopItem?.isCustom ?? false) {
                return (shopListItem.shopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty : shopListItem.shopItem?.readUserCategoryName() ?? Strings.empty
            }
            else {
                return shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty
            }
        })
        let sortedDictByName = groupItems.sorted{ $0.key > $1.key }
        self.sectionedIncompletedShopListItems.removeAll()
        let shopListOrders = self.planItShopList?.readCategoryOrder()
        for (key,value) in sortedDictByName {
            self.sectionedIncompletedShopListItems.append(ShopItemListSection(name: key, items: value, orderCategory: shopListOrders))
        }
        self.sectionedIncompletedShopListItems.sort { (section1, section2) -> Bool in
            if section1.isDefaultOrderValue() &&  section2.readOrderValue() == section1.readOrderValue() {
                return section1.readSectionName() > section2.readSectionName()
            }
            else {
                return section1.orderValue < section2.orderValue
            }
        }
        self.setVisibilityCategoryReorder()
        self.tableViewToDoItems?.reloadData()
    }
    
    func dismissListView() {
        var quantityChanges: Bool = false
        if let cellIndex = self.currentEditingCellIndex, let cell = self.tableViewToDoItems?.cellForRow(at: cellIndex) as? ShopItemListCell {
            if cell.textfieldQuantity?.isFirstResponder ?? false {
                cell.disableQuantityUpdate = true
                let savedQuantity = cell.planItShopListItem.quantity
                if let entireQuantity = cell.textfieldQuantity?.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if !entireQuantity.isEmpty && (savedQuantity != entireQuantity || savedQuantity == nil) {
                        quantityChanges = true
                    }
                }
            }
        }
        if quantityChanges {
            self.showAlertWithAction(message: Message.confirmSaveQuantity, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                if index == 0 {
                    if let cellIndex = self.currentEditingCellIndex, let cell = self.tableViewToDoItems?.cellForRow(at: cellIndex) as? ShopItemListCell {
                        if cell.textfieldQuantity?.isFirstResponder ?? false {
                            cell.disableQuantityUpdate = false
                            cell.textfieldQuantity?.resignFirstResponder()
                        }
                    }
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func manageCompletedSectionContainerSize() {
        if UIScreen.main.bounds.size.height * 0.85 == self.containerViewHeight.constant { return }
        self.containerViewHeight.constant = (self.view.frame.size.height * 0.85)
        self.constraintBottomContainer.constant = -(self.containerViewHeight.constant + self.getSafeAreaHeightBottom())
    }
    
    func showShopingListInformationIfExist(showCompleteList: Bool = false) {
        if let selectShopingList = self.planItShopList {
            self.activityIndicator.startAnimating()
            self.textViewShopListName.text = selectShopingList.readShopListName()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.allShopListItem = selectShopingList.readAllAvailableShopListItems().sorted(by: { return $0.readCreatedDate() < $1.readCreatedDate() }).map({ ShopListItemCellModel(planItShopListItem: $0) })
                self.buttonSelectAll?.isSelected = false
                self.viewItemSelection?.isHidden = true
                self.updateIncompletedShopListData()
                self.updateCompletedTable(showList: showCompleteList)
                if self.incompletedShopListItems.count > 0 && !showCompleteList {
                    self.stackViewEditAndCompleteShopItem.hideCompletedSection()
                }
                self.activityIndicator.stopAnimating()
            }
        }
        else {
            self.setVisibilityTopStackView()
            self.performSegue(withIdentifier: Segues.toCreateShoppingListScreen, sender: self)
        }
    }
    
    func setAddShoppingItemVC() {
        if self.shoppingItemListViewController == nil {
            self.shoppingItemListViewController = self.getShoppingItemListViewController()
        }
        guard let shoppingVC = self.shoppingItemListViewController else { return }
        self.addChild(shoppingVC)
        shoppingVC.view.frame = CGRect(x: 0, y: 0, width: self.containerShopListOptions.frame.size.width, height: (self.containerViewHeight.constant));
        self.containerShopListOptions.addSubview(shoppingVC.view)
        shoppingVC.didMove(toParent: self)
        self.maximizeShopListView()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(updateShopListDataFromNotification), name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil )
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil)
    }
    
    @objc func updateShopListDataFromNotification() {
        self.showShopingListInformationIfExist()
    }
    
    func setOnSearchActive() {
        self.viewSearch?.isHidden = false
        self.buttonBack.isHidden = true
        self.stackViewTop?.isHidden = true
        self.labelHeaderTitle.isHidden = true
        _ = self.textFieldSearch?.becomeFirstResponder()
    }
    
    func setOnEditModeActive(_ flag: Bool) {
        if flag {
            self.buttonEditCancel?.setTitle("Cancel", for: .normal)
        }
        self.buttonSelectAll?.isSelected = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.constraintTableViewBottom.constant = flag ? 100.0 : 16.0
            self.shopListMode = flag ? .edit : .default
            self.setVisibilityCategoryReorder(forceHide: flag)
            self.buttonSearch.isHidden = flag || self.incompletedShopListItems.isEmpty
            self.buttonList.isHidden = flag || self.incompletedShopListItems.isEmpty
            self.buttonMore?.isHidden = flag
            self.buttonHeaderEdit?.isHidden = flag || self.incompletedShopListItems.isEmpty
            self.viewEditView?.isHidden = !flag
            self.labelHeaderTitle.isHidden = flag
            self.buttonSelectAll?.isHidden = !(self.incompletedShopListItems.count > 1 && flag)
            self.buttonBack.isHidden = flag
            self.view.backgroundColor = .white
            self.stackViewEditAndCompleteShopItem.setVisibilityCompleteSection(!flag)
            if flag {
                self.stackViewEditAndCompleteShopItem.toggleCompleteSection(false)
            }
            self.stackViewEditAndCompleteShopItem.setActionView(mode: flag ? .edit : .default)
            self.containerShopListOptions.isHidden = flag
            self.labelShopListItemCount?.isHidden = flag || self.incompletedShopListItems.isEmpty
            self.updateSelectionLabelCount(0)
        }
    }
    
    func updateTitleCacelToDone() {
        self.buttonEditCancel?.setTitle("Done", for: .normal)
        self.updateSelectionLabelCount(self.incompletedShopListItems.filter({ $0.editSelected }).count)
    }
    
    func setBackToDefaultMode() {
        self.shopListMode = .default
        self.viewEditView?.isHidden = true
        self.labelHeaderTitle.isHidden = false
        self.buttonSelectAll?.isHidden = true
        self.stackViewEditAndCompleteShopItem.setActionView(mode: .default)
        self.viewSearch?.isHidden = true
        self.buttonBack.isHidden = false
        self.view.endEditing(true)
        self.view.backgroundColor = UIColor.init(red: 247 / 255.0, green: 246 / 255.0, blue: 251 / 255.0, alpha: 1.0)
        self.viewItemSelection?.isHidden = true
        self.textFieldSearch?.text = Strings.empty
        self.stackViewEditAndCompleteShopItem.resetCompleteSection()
        self.setVisibilityTopStackView()
        self.setVisibilityBGImage()
    }
    
    func startCompletedUndoTimer() {
        self.timerSyncCompleted = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireCompleteSyncTimer), userInfo: nil, repeats: false)
    }
    
    func resetShopListItemsBasedOnSearchAndSort() {
        var nonCompleteItems = self.allShopListItem.filter({ !$0.planItShopListItem.isCompletedLocal })
        if let viewSearch = self.viewSearch, !viewSearch.isHidden, let searchText = self.textFieldSearch?.text {
            if !searchText.isEmpty {
                nonCompleteItems = nonCompleteItems.filter({ (item) -> Bool in
                    let isInCategoryName = item.readShopItemCategoryName().lowercased().contains(searchText.lowercased())
                    let isInItemName = item.shopItem?.readItemName().lowercased().contains(searchText.lowercased()) ?? false
                    return (isInCategoryName || isInItemName)  && !item.planItShopListItem.isCompletedLocal
                })
                self.imageViewNoToDoItem?.isHidden = !nonCompleteItems.isEmpty
            }
            else {
                self.imageViewNoToDoItem?.isHidden = true
            }
        }
        if let sortValue = self.selectedSortValue {
            nonCompleteItems = self.sortShopListItemsBy(sortValue.dropDownType, ascending: self.buttonSortArrow?.isSelected ?? true, items: nonCompleteItems)
        }
        else {
            nonCompleteItems = self.sortShopListItemsBy(.eCategories, ascending: true, items: nonCompleteItems)
        }
        if self.selectedSortValue == nil || (self.selectedSortValue?.dropDownType != .eCategories) {
            self.incompletedShopListItems = nonCompleteItems
        }
    }
    
    func updateVisibilitySelectAndSortView() {
        self.buttonSelectAll?.isHidden = self.incompletedShopListItems.isEmpty || self.shopListMode != .edit
    }
    
    func resetShopListItemsAfterFavorite() {
        self.resetShopListItemsBasedOnSearchAndSort()
        self.shoppingItemListViewController?.updateFavoritedShopListItems()
    }
    
    func resetShopListItemsAfterComplete() {
        self.resetShopListItemsBasedOnSearchAndSort()
        self.updateVisibilitySelectAndSortView()
        self.setVisibilityTopStackView()
    }
    
    func resetShopListItemsAfterMove() {
        if !self.stackViewEditAndCompleteShopItem.tableViewShopListItems.isHidden {
            self.updateCompletedTable(showList: false)
        }
        self.resetShopListItemsBasedOnSearchAndSort()
        self.updateVisibilitySelectAndSortView()
        self.setVisibilityTopStackView()
        self.setVisibilityBGImage()
    }
    
    func resetShopListItemsAfterDelete() {
        self.resetShopListItemsBasedOnSearchAndSort()
        self.updateVisibilitySelectAndSortView()
        self.setVisibilityTopStackView()
        self.setVisibilityBGImage()
    }
    
    func updateUndoSection(on todos: [PlanItShopListItems]) {
        self.completedQueue.append(contentsOf: todos)
        if self.viewCompletedPopUp.isHidden && self.timerSyncCompleted == nil {
            self.startCompletedUndoTimer()
        }
        self.labelUndoCompletedCount.text = "Completed (\(self.completedQueue.count))"
        self.viewCompletedPopUp.isHidden = self.completedQueue.count == 0
        self.updateSelectionLabelCount(self.incompletedShopListItems.filter({ $0.editSelected }).count)
    }
    
    func updateCompletedTable(showList: Bool = true) {
        let completedItem = self.allShopListItem.filter({ $0.planItShopListItem.isCompletedLocal })
        var showFlag = showList
        if completedItem.isEmpty {
            showFlag = false
        }
        self.stackViewEditAndCompleteShopItem.setCompletedItems(items: self.allShopListItem.filter({ $0.planItShopListItem.isCompletedLocal }), showList: showFlag)
        self.setVisibilityTopStackView()
        self.checkVisibilitystackViewEditAndComplete()
    }
    
    func checkVisibilitystackViewEditAndComplete() {
        if self.shopListMode == .edit {
            self.stackViewEditAndCompleteShopItem.viewCompleteSection.isHidden = true
            self.stackViewEditAndCompleteShopItem.tableViewShopListItems.isHidden = true
        }
    }
    
    @objc func fireCompleteSyncTimer() {
        self.timerSyncCompleted = nil
        self.viewCompletedPopUp.isHidden = true
        self.completedQueue.removeAll()
        self.updateCompletedTable(showList: false)
    }
    
    func undoCompleteShopListItem() {
        self.timerSyncCompleted?.invalidate()
        self.timerSyncCompleted = nil
        self.viewCompletedPopUp.isHidden = true
        self.saveShopListItemCompleteToServerUsingNetwotk(self.completedQueue, with: false)
        self.completedQueue.removeAll()
    }
    
    func checkForAllCellSelected() {
        if let buttonSelect = self.buttonSelectAll, !buttonSelect.isHidden{
            self.buttonSelectAll?.isSelected = self.incompletedShopListItems.filter({ !$0.editSelected }).count == 0
        }
    }
    
    func updateSelectionLabelCount(_ count: Int) {
        self.viewItemSelection?.isHidden = count == 0
        self.labelItemSelectionCount?.text = "\(count) item selected"
    }
    
    func getShoppingItemListViewController() -> ShoppingItemListViewController {
        let storyboard = UIStoryboard(name: "ShoppingList", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ShoppingItemListViewController") as! ShoppingItemListViewController
        viewController.delegate = self
        viewController.currentPlanItShopList = self.planItShopList
        return viewController
    }
    
    func checkAnyPendingShopListItem() {
        
    }
    
    func minimizeShopListView() {
        guard self.shoppingItemListViewController != nil else { return }
        self.viewOverlay.isHidden = true
        self.constraintBottomContainer.constant = -(self.containerViewHeight.constant - 90)
        self.buttonCloseShopList.isHidden = true
        self.shoppingItemListViewController?.setCloseButton(toMinimize: true)
        self.shoppingItemListViewController?.viewOverlay.isHidden = false
        self.view.endEditing(true)
    }
    
    func maximizeShopListView() {
        self.viewOverlay.isHidden = false
        self.constraintBottomContainer.constant = 0
        self.buttonCloseShopList.isHidden = false
        self.shoppingItemListViewController?.setCloseButton(toMinimize: false)
        self.shoppingItemListViewController?.viewOverlay.isHidden = true
    }
    
    func sortShopListItemsBy(_ type: DropDownOptionType, ascending: Bool, items: [ShopListItemCellModel]) -> [ShopListItemCellModel] {
        let sortData: [ShopListItemCellModel] = items
        switch type {
        case .eAlphabetically:
            return sortData.sorted { (shopItem1, shopItem2) -> Bool in
                guard let shopName1 = shopItem1.shopItem?.readItemName(), let shopName2 = shopItem2.shopItem?.readItemName() else { return false }
                return shopName1.localizedCaseInsensitiveCompare(shopName2) == (ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending)
            }
        case .eCreatedDate:
            return sortData.sorted { (shopItem1, shopItem2) -> Bool in
                guard let shopListItem1Date = shopItem1.planItShopListItem.createdDate, let shopListItem2Date = shopItem2.planItShopListItem.createdDate else { return false }
                return shopListItem1Date.compare(shopListItem2Date) == (ascending ? .orderedAscending : .orderedDescending)
            }
        case .eDueDate:
            let sortedDueDate = sortData.sorted { (shopItem1, shopItem2) -> Bool in
                return (shopItem1.planItShopListItem.dueDate ?? Date().adding(years: -50)).compare(shopItem2.planItShopListItem.dueDate ?? Date().adding(years: -50)) == (ascending ? .orderedAscending : .orderedDescending)
            }
            return sortedDueDate
        case .eFavourite:
            return sortData.sorted { (shopItem1, shopItem2) -> Bool in
                guard let shop1 = shopItem1.planItShopListItem, let shop2 = shopItem2.planItShopListItem else { return false }
                return ascending ? shop1.isFavoriteLocal && !shop2.isFavoriteLocal : !shop1.isFavoriteLocal && shop2.isFavoriteLocal
            }
        case .eCategories:
            self.sortByShopItemCategory(ascending: ascending)
            return sortData
        default:
            break
        }
        return []
    }
    
    func sortByShopItemCategory(ascending: Bool) {
        self.sectionedIncompletedShopListItems.sort { (shopItemListSection1, shopItemListSection2) -> Bool in
            return ascending ? shopItemListSection1.sectionName < shopItemListSection2.sectionName : shopItemListSection1.sectionName >
                shopItemListSection2.sectionName
        }
        self.tableViewToDoItems?.reloadData()
    }
    
    func sortPrintShopListItemsBy(_ type: DropDownOptionType, ascending: Bool) -> [ShopListItemCellModel] {
        var sortArray = self.allShopListItem
        switch type {
        case .eAlphabetically:
            sortArray.sort { (shopItem1, shopItem2) -> Bool in
                guard let shopName1 = shopItem1.shopItem?.readItemName(), let shopName2 = shopItem2.shopItem?.readItemName() else { return false }
                return shopName1.localizedCaseInsensitiveCompare(shopName2) == (ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending)
            }
        case .eCreatedDate:
            sortArray.sort { (shopItem1, shopItem2) -> Bool in
                guard let shopListItem1Date = shopItem1.planItShopListItem.createdDate, let shopListItem2Date = shopItem2.planItShopListItem.createdDate else { return false }
                return shopListItem1Date.compare(shopListItem2Date) == (ascending ? .orderedAscending : .orderedDescending)
            }
        case .eFavourite:
            sortArray.sort { (shopItem1, shopItem2) -> Bool in
                guard let shop1 = shopItem1.planItShopListItem, let shop2 = shopItem2.planItShopListItem else { return false }
                return ascending ? shop1.isFavorite && !shop2.isFavorite : !shop1.isFavorite && shop2.isFavorite
            }
        default:
            break
        }
        return sortArray
    }
    
    func getCategoryName(item: ShopListItemCellModel) -> String {
        if item.planItShopListItem.isShopCustomItem {
            let mainCategoryName = (item.shopItem?.readMasterCategoryName() ?? Strings.empty)
            return !(item.shopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? item.shopItem?.readUserCategoryName() ?? Strings.empty : (mainCategoryName.isEmpty ? "Others" : mainCategoryName)
        }
        else {
            let masterCategory = item.shopItem?.readMasterCategoryName() ?? Strings.empty
            return !masterCategory.isEmpty ? masterCategory : "Others"
        }
    }
    
    
    func printShoppingList() {
        if self.allShopListItem.count > 0 {
            let sortedShopItems = self.allShopListItem.sorted(by: {
                guard let item1 = $0.shopItem?.readItemName(), let item2 =  $1.shopItem?.readItemName() else {
                    return false
                }
                return (self.getCategoryName(item: $0), item1) <
                    (self.getCategoryName(item: $1), item2)
            })
            let distinctCategories = Array(Set(sortedShopItems.map({ self.getCategoryName(item: $0) })))
            var html = "<!DOCTYPE html><html><meta charset=\"UTF-8\"><head><title>To Do List</title><style>body {background-color: white;text-align: center;color: black;font-family: Arial, Helvetica, sans-serif;}li.style1 {text-align: left;font-size: 15px;font-weight: bold;line-height: 25px}li.style2 {text-align: left;font-size: 13px;line-height: 25px}hr.newstyle {border-top: 1px dashed black;} span.style1 {text-align: left;font-size: 12px;line-height: 15px;color:gray;}span.style2 {text-align: left;font-size: 14px;line-height: 15px;color:black;}h2.style1 {text-align: left;}</style></head><body>"
            if let filepath = Bundle.main.path(forResource: "base64image", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    html.append("<p><img src=\"data:image/jpg;base64, \(contents)\" alt=\"Logo Image\" width=\"40\" height=\"40\" /></p>")
                    
                } catch {
                    // contents could not be loaded
                }
            }
            html.append("<h1><u>\(self.planItShopList?.shopListName ?? Strings.unavailable) </u></h1>")
            if let sharedBy = self.planItShopList?.createdBy, sharedBy.readValueOfUserId() != Session.shared.readUserId() {
                html.append("<h2 class = 'style1'> Shared By: \(sharedBy.fullName ?? Strings.empty)</h2>")
            }
            html.append("<ul>")
            var lastCategory = Strings.empty
            for shoppingItem in sortedShopItems {
                let categoryName = self.getCategoryName(item: shoppingItem)
                if categoryName != lastCategory {
                    if !lastCategory.isEmpty {
                        html.append("</li>")
                    }
                    html.append("<li class = 'style1'>\(categoryName)")
                    lastCategory = categoryName
                }
                if shoppingItem.planItShopListItem.readIsCompleted() == true {
                    html.append("<br>&#10003;&emsp;")
                }
                else {
                    html.append("<br>&#9744;&emsp;")
                }
                if !shoppingItem.planItShopListItem.readQuantity().isEmpty {
                    html.append("<span class = 'style1'>\(shoppingItem.shopItem?.readItemName() ?? Strings.empty) &emsp;&emsp; Qty:  \(shoppingItem.planItShopListItem.readQuantity())</span>")
                }
                else {
                    html.append("<span class = 'style1'>\(shoppingItem.shopItem?.readItemName() ?? Strings.empty)</span>")
                }
                
            }
            html.append("</li></ul></body></html>")
            let data = Data(html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                let print = UISimpleTextPrintFormatter(attributedText: attributedString)
                let vc = UIActivityViewController(activityItems: [print], applicationActivities: nil)
                present(vc, animated: true)
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.noitemstoprint])
        }
    }
}

extension AddShoppingItemsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldSearch {
            if self.textFieldSearch?.text == Strings.empty {
                self.setBackToDefaultMode()
            }
            textField.resignFirstResponder()
            return false
        }
        if (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) != nil {
            return true
        }
        else {
            debugPrint("Show valid error message")
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true
    }
}

extension AddShoppingItemsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            if let shopListName = self.textViewShopListName.text, !shopListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, self.planItShopList?.readShopListName() != shopListName {
                self.saveShopListItemUpdateNameServerUsingNetwotk(shopListName)
            }
        }
        textView.returnKeyType = ((textView.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && text.isEmpty) ? .default : .done
        textView.reloadInputViews()
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
    }
}


extension AddShoppingItemsViewController: NormalSpeechTextFieldDelegate {
    func normalSpeechTextField(_ normalSpeechTextField: NormalSpeechTextField, test: String) {
        self.searchResultOfShoppingList()
    }
}

extension AddShoppingItemsViewController {
    
    func updateShopItemCount() {
        self.labelShopListItemCount?.text = !self.incompletedShopListItems.isEmpty ? (self.incompletedShopListItems.count > 99 ? "99+" : "\(self.incompletedShopListItems.count)") : Strings.empty
        self.labelShopListItemCount?.isHidden = self.incompletedShopListItems.isEmpty || self.shopListMode == .edit
        self.viewListCount?.isHidden = self.incompletedShopListItems.isEmpty
    }
    
    func removeSearch() {
        self.textFieldSearch?.text = Strings.empty
        self.resetShopListItemsBasedOnSearchAndSort()
        self.setBackToDefaultMode()
        self.imageViewNoToDoItem?.isHidden = true
    }
    
    func searchResultOfShoppingList() {
        self.resetShopListItemsBasedOnSearchAndSort()
    }
    
    func updateIncompletedShopListData() {
        self.resetShopListItemsBasedOnSearchAndSort()
        self.setVisibilityBGImage()
    }
    
    func addShopItemInList(_ item: ShopListItemDetailModel) {
        guard let shopList = self.planItShopList else { return }
        
        if item.planItShopItem == nil {
            // new custom item save
            self.saveNewCustomShopListItemToServerUsingNetwotk(item)
        }
        else {
            var newShopListItem = item.planItShopListItem
            if item.planItShopListItem == nil {
                 newShopListItem = DatabasePlanItShopListItem().insertShopListItem(item, planItShopList: shopList)
            }
            if let planItshopListItem = newShopListItem {
                let newShopItem = ShopListItemCellModel(planItShopListItem: planItshopListItem)
                self.allShopListItem.append(newShopItem)
                self.updateIncompletedShopListData()
                self.setVisibilityTopStackView()
                if planItshopListItem.shopListItemId == 0 {
                    self.saveShopListItemToServerUsingNetwotk([planItshopListItem], shopListItemCellModel: newShopItem)
                }
            }
            // update shop items collection of category
            if let planItShopItem =  item.planItShopItem, planItShopItem.isCustom, planItShopItem.readUserCategoryIdLocalValue() != planItShopItem.readUserCategoryIdValue() {
                self.shoppingItemListViewController?.updateShopItemsOfCategory()
                self.stackViewEditAndCompleteShopItem.updateSectionCompleteShopListItemIfShopItemExist(item: planItShopItem)
            }
        }
        if !self.incompletedShopListItems.isEmpty {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.viewListCount?.flash()
            self.labelShopListItemCount?.flash()
        }
    }
    
    func addMultipleShopItemInList(_ item: [ShopListItemDetailModel]) {
       // API multi ple select
    }
    
    func appendShopItemInList(_ item: ShopListItemDetailModel) {
        guard let planItShopListItem = item.planItShopListItem else { return }
        self.allShopListItem.append(ShopListItemCellModel(planItShopListItem: planItShopListItem))
        self.updateIncompletedShopListData()
        self.setVisibilityTopStackView()
    }
    
    func checkIncompletedShopItemAlreadyExist(_ shopItem: ShopListItemDetailModel) -> ShopListItemCellModel? {
        if let shopItem = self.incompletedShopListItems.filter({ $0.shopItem == shopItem.planItShopItem }).first {
            return shopItem
        }
        return nil
    }
    
    func checkCompleteShopItemAlreadyExist(_ shopItem: ShopListItemDetailModel) -> ShopListItemCellModel? {
        if let shopItem = self.allShopListItem.filter({ $0.shopItem == shopItem.planItShopItem && $0.planItShopListItem.isCompletedLocal }).first {
            return shopItem
        }
        return nil
    }
    
    func showMessageOnAddedOnCompleteItem(_ shopListItemDetailModel: ShopListItemDetailModel, toDetailScreen flag: Bool) {
        self.showAlertWithAction(message: Message.confirmationAddCompletedShopItem, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.view.endEditing(true)
                if flag {
                    self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: shopListItemDetailModel)
                }
                else {
                    self.minimizeShopListView()
                    self.addShopItemInList(shopListItemDetailModel)
                }
            }
            else {
                // dont add
            }
        })
    }
    
    func showMessageOnAddedOnInCompleteItem(_ shopListItemCellModel: ShopListItemCellModel, quantity: String) {
        self.showAlertWithAction(message: Message.confirmationAddInCompletedShopItem, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.view.endEditing(true)
                // edit already added item
                self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: (shopListItemCellModel, quantity))
            }
            else {
                // don't edit
                self.view.endEditing(true)
                self.shoppingItemListViewController?.resetShopItemCategoryCollectionScroll()
            }
        })
    }
    
    func confirmationCheckOnAdd(shopItem: ShopListItemDetailModel, toDetailScreen flag: Bool = false) {
        if let existingItem = self.checkIncompletedShopItemAlreadyExist(shopItem) {
            self.showMessageOnAddedOnInCompleteItem(existingItem, quantity: shopItem.quantity.isEmpty ? existingItem.shopListItemQuantity : shopItem.quantity)
        }
        else if self.checkCompleteShopItemAlreadyExist(shopItem) != nil {
            self.showMessageOnAddedOnCompleteItem(shopItem, toDetailScreen: flag)
        }
        else if flag {
            self.view.endEditing(true)
            self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: shopItem)
        }
        else {
            //self.minimizeShopListView()
            self.addShopItemInList(shopItem)
        }
    }
    
    func addSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.containerShopListOptions.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.containerShopListOptions.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .up {
            self.maximizeShopListView()
        }
        else if gesture.direction == .down {
             self.minimizeShopListView()
        }
        UIView.animate(withDuration: 0.3) {
            self.containerShopListOptions.layoutIfNeeded()
        }
    }
    
    func validateOfflineSyncData(_ shopListItems: [PlanItShopListItems]) -> Bool {
        let anyPendingShopItems = shopListItems.filter({ $0.isShopItemPending() })
        let anyPendingShopItemCategory = shopListItems.filter({ $0.isShopItemCategoryPending() })
        let anyPendingShopListItem = shopListItems.filter({ $0.isPending })
        if anyPendingShopItems.isEmpty && anyPendingShopItemCategory.isEmpty && anyPendingShopListItem.isEmpty, let shopList = self.planItShopList, !shopList.isPending {
            return true
        }
        return false
    }
    
    func updateMainCategoryList() {
        guard let shopList = self.planItShopList else { return }
        self.delegate?.addShoppingItemsViewController(self, onUpdate: shopList)
    }
    
    func getSafeAreaHeightBottom() -> CGFloat {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets.bottom
    }
    
    func refreshUpdateItemDetail(_ addUpdateItemDetail: ShopListItemDetailModel) {
        if self.allShopListItem.filter({ $0.planItShopListItem == addUpdateItemDetail.planItShopListItem }).isEmpty {
            self.appendShopItemInList(addUpdateItemDetail)
        }
        else if let shopListItemCellModel = self.allShopListItem.filter({ $0.planItShopListItem == addUpdateItemDetail.planItShopListItem }).first {
            shopListItemCellModel.shopListItemQuantity = addUpdateItemDetail.quantity
        }
        if let sortValue = self.selectedSortValue {
            self.incompletedShopListItems = self.sortShopListItemsBy(sortValue.dropDownType, ascending: self.buttonSortType?.isSelected ?? true, items: self.incompletedShopListItems)
        }
        self.updateCompletedTable(showList: false)
        self.updateIncompletedShopListData()
        self.updateMainCategoryList()
    }
}
