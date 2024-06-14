//
//  CompletedShopItemStackView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol EditAndCompleteShopItemStackViewDelegate: class {
    func editAndCompleteShopItemStackViewMoveAll(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackViewUncompleteAll(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, unCompleteShopItem: PlanItShopListItems)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onFavouriteToDo: ToDoItemCellModel, flag: Bool)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onDeleteShopListItem: PlanItShopListItems)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onSelectShopItem: ShopListItemCellModel)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, popAttachmentShopItem: ShopListItemCellModel)
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, setOverlay flag: Bool)
    
    func editAndCompleteShopItemStackViewOnMove(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackViewOnFavorite(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackViewOnComplete(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackViewOnDelete(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
    func editAndCompleteShopItemStackViewOnChangeDueDate(_ completedShopItemStackView: EditAndCompleteShopItemStackView)
}

class EditAndCompleteShopItemStackView: UIStackView {
    
    weak var delegate: EditAndCompleteShopItemStackViewDelegate?
    var completedItems: [ShopListItemCellModel] = [] {
        didSet {
            self.updateSectionIncompleteShopListItem()
            self.viewCompleteSection.isHidden = completedItems.count == 0
            self.labelCompleted?.text = "COMPLETED (\(completedItems.count))"
        }
    }
    
    var sectionedCompletedShopListItems: [ShopItemListSection] = []
    
    @IBOutlet weak var tableViewShopListItems: UITableView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var viewCompleteSection: UIView!
    @IBOutlet weak var viewAction: UIView!
    @IBOutlet weak var labelCompleted: UILabel?
    @IBOutlet weak var viewDismissTap: UIView!
    @IBOutlet weak var buttonUncompleteAll: UIButton!
    @IBOutlet weak var buttonMoveAll: UIButton?
    
    @IBAction func toggleShowToDoClicked(_ sender: UIButton) {
        self.toggleCompletedShopList(show: !self.buttonArrow.isSelected)
    }
    
    func toggleCompletedShopList(show flag: Bool) {
        self.viewDismissTap.isHidden = !flag
        self.buttonArrow.isSelected = flag
        self.buttonArrow.isHidden = flag
        self.delegate?.editAndCompleteShopItemStackView(self, setOverlay: flag)
        self.buttonUncompleteAll.isHidden = !flag
        self.buttonMoveAll?.isHidden = !flag
        flag ? self.tableViewShopListItems.showAnimated(in: self) : self.tableViewShopListItems.hideAnimated(in: self)
    }
    
    func hideCompletedSection() {
        self.buttonArrow.isSelected = false
        self.tableViewShopListItems.isHidden = true
    }
    
    func updateSectionIncompleteShopListItem() {
        let groupItems = Dictionary(grouping: self.completedItems, by: { shopListItem -> String in
            if (shopListItem.shopItem?.isCustom ?? false) {
                return (shopListItem.shopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty : shopListItem.shopItem?.readUserCategoryName() ?? Strings.empty
            }
            else {
                return shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty
            }
        })
        let sortedDictByName = groupItems.sorted{ $0.key > $1.key }
        self.sectionedCompletedShopListItems.removeAll()
        var otherGroupItems: [ShopItemListSection] = []
        for (key,value) in sortedDictByName {
            if key == "Others" {
                otherGroupItems.append(ShopItemListSection(name: key, items: value))
            }
            else {
                self.sectionedCompletedShopListItems.append(ShopItemListSection(name: key, items: value))
            }
        }
        self.sectionedCompletedShopListItems.append(contentsOf: otherGroupItems)
        self.tableViewShopListItems?.reloadData()
    }
    
    func updateSectionCompleteShopListItemIfShopItemExist(item: PlanItShopItems) {
        if !self.completedItems.filter({ $0.shopItem == item }).isEmpty {
            self.updateSectionIncompleteShopListItem()
        }
    }
    
    func setCompletedItems(items: [ShopListItemCellModel], showList: Bool) {
        self.completedItems = items
        if showList || self.completedItems.isEmpty {
            self.setVisibilityCompleteSection(!self.completedItems.isEmpty ? showList : false)
            self.toggleCompleteSection(showList)
        }
    }
    
    func removeDeletedItemsFromCompletedList() {
        //self.completedItems.removeAll(where: { return $0.planItShopList.readDeleteStatus() })
    }
    
    func refreshCategoriesAfterUserFavouriteTodos() {
        self.tableViewShopListItems.reloadData()
    }
    
    func setActionView(mode: ToDoMode) {
        self.viewAction.isHidden = mode == .default
    }
    
    func setVisibilityCompleteSection(_ flag: Bool) {
        self.viewCompleteSection.isHidden = !flag || self.completedItems.isEmpty
    }
    
    func toggleCompleteSection(_ flag: Bool) {
        self.tableViewShopListItems.isHidden = !flag || self.completedItems.isEmpty
        self.buttonArrow.isSelected = flag
        self.toggleCompletedShopList(show: flag)
    }
    
    func resetCompleteSection() {
        self.viewCompleteSection.isHidden = completedItems.count == 0
    }

    @IBAction func setFavoriteClicked(_ sender: UIButton) {
        self.delegate?.editAndCompleteShopItemStackViewOnFavorite(self)
    }
    
    @IBAction func moveToClicked(_ sender: UIButton) {
        self.delegate?.editAndCompleteShopItemStackViewOnMove(self)
    }
    
    @IBAction func completeClicked(_ sender: UIButton) {
        self.delegate?.editAndCompleteShopItemStackViewOnComplete(self)
    }
    
    @IBAction func deleteClicked(_ sender: UIButton) {
        self.delegate?.editAndCompleteShopItemStackViewOnDelete(self)
    }
    
    @IBAction func unCompleteAllClicked(_ sender: Any) {
        self.delegate?.editAndCompleteShopItemStackViewUncompleteAll(self)
    }
    
    @IBAction func dueDateClicked(_ sender: UIButton) {
        self.delegate?.editAndCompleteShopItemStackViewOnChangeDueDate(self)
    }
    
    @IBAction func moveAllClicked(_ sender: Any) {
        self.delegate?.editAndCompleteShopItemStackViewMoveAll(self)
    }

}


extension EditAndCompleteShopItemStackView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionedCompletedShopListItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionedCompletedShopListItems[section].shopListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemListCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shopListCompletedItemCell, for: indexPath) as! ShopItemListCell
        cell.configCompletedCell(index: indexPath, shopListItem: self.sectionedCompletedShopListItems[indexPath.section].shopListItems[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.completedItems.count - 1 ? 75 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: section == self.completedItems.count - 1 ? 75 : 10))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.delegate?.editAndCompleteShopItemStackView(self, onDeleteShopListItem: self.sectionedCompletedShopListItems[indexPath.section].shopListItems[indexPath.row].planItShopListItem)
        })
        deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
        deleteAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shoppingListItemHeaderTableViewCell) as! ShoppingListItemHeaderTableViewCell
        cell.configCell(categoryName: self.sectionedCompletedShopListItems[section].sectionName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}



extension EditAndCompleteShopItemStackView: ShopItemListCellDelegate {
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, showAttachment indexPath: IndexPath) {
        self.delegate?.editAndCompleteShopItemStackView(self, popAttachmentShopItem: shopItemListCell.shopListItem)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, completion flag: Bool, indexPath: IndexPath) {
        self.delegate?.editAndCompleteShopItemStackView(self, unCompleteShopItem: shopItemListCell.planItShopListItem)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, didSelect indexPath: IndexPath) {
        self.delegate?.editAndCompleteShopItemStackView(self, onSelectShopItem: shopItemListCell.shopListItem)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, checkBoxSelect indexPath: IndexPath) {
        
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, shopListOn indexPath: IndexPath, quantity: String) {
        
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, ShouldBeginEditing indexPath: IndexPath) {
        
    }
    
}

