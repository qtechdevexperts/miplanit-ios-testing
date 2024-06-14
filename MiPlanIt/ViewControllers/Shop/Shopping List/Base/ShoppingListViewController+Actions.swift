//
//  ShoppingListViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 04/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingListViewController {
    
    func initialUIComponents() {
                self.showInterstitalViewController()

        self.constraintSearchViewHeight.constant = 0
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.readAllUserShoppingList(fromLaunch: true)
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        self.createServiceToMasterData()
    }
    
    func shopPullToRefresh() {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShopListDataFromNotification), name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil )
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil)
    }
    
    @objc func updateShopListDataFromNotification() {
        self.readAllUserShoppingList()
    }
    
    func readAllUserShoppingList(fromLaunch: Bool = false)  {
        let localShoppingList = DatabasePlanItShopList().readAllUserShopList().sorted(by: { return $0.readCreatedDate() > $1.readCreatedDate() })
        if !localShoppingList.isEmpty || !fromLaunch {
            self.allShoppingList = localShoppingList
        }
    }
    
    func startLottieAnimations() {
        if self.allShoppingList.isEmpty {
            self.viewFetchingData.isHidden = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
        }
    }
    
    func stopLottieAnimations() {
        if self.allShoppingList.isEmpty {
            self.viewFetchingData.isHidden = true
            UIApplication.shared.endIgnoringInteractionEvents()
            if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
        }
    }
    
    func showErrorMessage(_ message: String) {
        if self.allShoppingList.isEmpty {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
        }
    }
    
    
    
    @objc func deleteItemClicked(on indexPath: IndexPath) {
        
    }
    
    func deleteShopList(on indexPath: IndexPath) {
        self.showAlertWithAction(message: Message.deleteShoppingListMessage, title: Message.deleteShoppingList, items: [Message.yes, Message.cancel], callback: { index in
            if index == 0 {
                if let cell = self.tableView.cellForRow(at: indexPath) as? ShoppingListTableViewCell {
                    if self.categories[indexPath.section].items[indexPath.row].createdBy?.readValueOfUserId() != Session.shared.readUserId() {
                        self.removeShopListToServerUsingNetwotk(self.categories[indexPath.section].items[indexPath.row], cell: cell)
                    }
                    else {
                        self.deleteShopListToServerUsingNetwotk(self.categories[indexPath.section].items[indexPath.row], cell: cell)
                    }
                }
            }
        })
    }
    
    func removeShoppingList(_ deletedShopList: PlanItShopList) {
        self.allShoppingList.removeAll { (shopList) -> Bool in
            if shopList.readShopListIDValue() != 0 {
                return shopList.readShopListIDValue() == deletedShopList.readShopListIDValue()
            }
            else {
                return shopList.readAppShopListID() == deletedShopList.readAppShopListID()
            }
        }
    }
    
    func updateSearchHeight(sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.constraintSearchViewHeight.constant = self.constraintSearchViewHeight.constant == 55 ? 0 : 55
        }
    }
    
    func showShoppingListBasedOnSearchCriteria() {
        guard let text = self.textFieldSearch.text else { return }
        self.searchShoppingListUsingText(text)
    }
    
    func saveShopListItemInviteesToServerUsingNetwotk(_ invitees: [OtherUser]) {
        guard let shopList = self.selectedShopList else { return }
        if SocialManager.default.isNetworkReachable() && !shopList.isPending {
            self.updateInvitees(invitees)
        }
        else if let user = Session.shared.readUser() {
            var sharedUser: [OtherUser] = invitees
            if !invitees.isEmpty {
                let selfUser = OtherUser(planItUser: user)
                selfUser.sharedStatus = 1.0
                sharedUser.append(selfUser)
            }
            shopList.updateShopListItemInvitees(sharedUser)
            self.tableView.reloadData()
        }
    }
    
    func printShoppingList(selected: PlanItShopList) {
        let allShopListItem = selected.readAllAvailableShopListItems().map({ ShopListItemCellModel(planItShopListItem: $0) })
        if allShopListItem.count > 0 {
            let sortedShopItems = allShopListItem.sorted(by: {
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
            html.append("<h1><u>\(selected.shopListName ?? Strings.unavailable) </u></h1>")
            if let sharedBy = selected.createdBy, sharedBy.readValueOfUserId() != Session.shared.readUserId() {
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
    
}
