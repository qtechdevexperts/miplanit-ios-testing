//
//  ShoppingItemDetailViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShoppingItemDetailViewController {
    
    func initializeUI() {
        self.datePicker.minimumDate = Date()
        self.textfieldQuantityCount.text = self.shopItemDetailModel.quantity
        if !self.shopItemDetailModel.categoryName.isEmpty {
            self.labelCategoryName.text = self.shopItemDetailModel.categoryName
        }
        self.textViewItemName.text = self.shopItemDetailModel.itemName
        if let shopListItem = self.shopItemDetailModel.planItShopListItem {
            self.buttonDelete.isHidden = shopListItem.shopListItemId == 0.0 && shopListItem.readappShopListItemId().isEmpty
        }
        else {
            self.buttonDelete.isHidden = true
        }
        self.buttonFavorite.isSelected = self.shopItemDetailModel.isfavoriteLocal
        self.buttonChangeCategory.isHidden = !(self.shopItemDetailModel.planItShopItem?.isCustom ?? true)
        self.buttonChangeCategoryArrow.isHidden = !(self.shopItemDetailModel.planItShopItem?.isCustom ?? true)
        self.textFieldStoreName.text = self.shopItemDetailModel.store
        self.textFieldBrandName.text = self.shopItemDetailModel.brand
        self.textFieldTargetPrice.text = self.shopItemDetailModel.targetPrize
        self.textFieldUrl.text = self.shopItemDetailModel.url
        self.textAreaNotes.text = self.shopItemDetailModel.notes
        self.labelShopListName.text =  self.shopItemDetailModel.shopListName
        self.imageViewItem.image = UIImage(named: Strings.defaultShopItemImage)
        if let shopItem = self.shopItemDetailModel.planItShopItem {
            self.imageViewItem.pinImageFromURL(URL(string: shopItem.readImageName()), placeholderImage: UIImage(named: Strings.defaultShopItemImage))
        }
        self.buttonCheckMarkAsComplete?.isHidden = self.shopItemDetailModel.planItShopListItem == nil
        self.buttonFavorite?.isHidden = self.shopItemDetailModel.planItShopListItem == nil
        self.textViewItemName.isUserInteractionEnabled = self.shopItemDetailModel.planItShopItem?.isCustom ?? true
        self.buttonUrlLink.isHidden = self.shopItemDetailModel.url.isEmpty
        self.showTagsCount()
        self.showAttachmentsCount()
        self.updateDueDate(date: self.shopItemDetailModel.dueDate)
        self.updateRemindMeTitle()
        self.viewAddAttachment.isHidden = !self.shopItemDetailModel.attachments.isEmpty
        self.pageControlAttachment.numberOfPages = self.shopItemDetailModel.attachments.count
        self.pageControlAttachment.isHidden = self.shopItemDetailModel.attachments.count <= 1
        self.dayDatePicker?.dataSource = self.dayDatePicker
        self.dayDatePicker?.delegate = self.dayDatePicker
        self.dayDatePicker?.dayDatePickerDelegate = self
        self.dayDatePicker?.setUpData()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.dayDatePicker?.setValue(UIColor.white, forKeyPath: "textColor")
//        self.labelDueDate.textColor = .white
    }
    
    func updateDueDateChanged(_ date: Date) {
        self.updateDueDate(date: date)
        self.labelDueDate.text = "Due " + date.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.buttonRemoveDueDate.isHidden = false
        self.viewOverlayReminder.isHidden = true
    }
    
    func validateSave() -> Bool {
        if self.shopItemDetailModel.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.shopItemNameBlankTitle])
            return false
        }
//        else if  self.shopItemDetailModel.dueDate == nil{
//            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.shopItemDueDateBlank])
//            return false
//        }
        else if DatabasePlanItShopItems().readContainShopItemOfName(self.shopItemDetailModel.itemName.trimmingCharacters(in: .whitespacesAndNewlines), planItShopItem: self.shopItemDetailModel.planItShopItem) {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.shopItemAlreadyExist])
            return false
        }
        return true
    }
    
    func updateDueDate(date: Date?) {
        guard let dueDate = date else {
            self.shopItemDetailModel.dueDate = nil
            return
        }
        self.shopItemDetailModel.dueDate = dueDate
        self.labelDueDate.text = "Due " + (self.shopItemDetailModel.dueDate ?? Date()).stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.datePicker.date = (self.shopItemDetailModel.dueDate ?? Date())
        self.dayDatePicker?.selectRow(self.dayDatePicker?.selectedDate(date: (self.shopItemDetailModel.dueDate ?? Date())) ?? 0, inComponent: 0, animated: true)
//        self.labelDueDate.textColor = .black
        self.buttonRemoveDueDate.isHidden = false
    }
    
    func showTagsCount() {
        self.labelShoppingTagCount.text = "\(self.shopItemDetailModel.tags.count)"
        self.labelShoppingTagCount.isHidden = self.shopItemDetailModel.tags.isEmpty
    }
    
    func showAttachmentsCount() {
        self.labelAttachmentCount.text = "\(self.shopItemDetailModel.attachments.count)"
        self.labelAttachmentCount.isHidden = self.shopItemDetailModel.attachments.isEmpty
    }
    
    func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func startPendingUploadOfAttachment() {
        if let pendingAttachMent = self.shopItemDetailModel.attachments.filter({ return $0.identifier.isEmpty }).first {
            self.saveShopListItemAttachmentsToServerUsingNetwotk(pendingAttachMent)
        }
        else {
            self.saveShopListItemDetailsToServerUsingNetwotk()
        }
    }
    
    func updateModelWithData() {
        self.shopItemDetailModel.quantity = self.textfieldQuantityCount.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "1"
        self.shopItemDetailModel.store = self.textFieldStoreName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.shopItemDetailModel.brand = self.textFieldBrandName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.shopItemDetailModel.targetPrize = self.textFieldTargetPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.shopItemDetailModel.url = self.textFieldUrl.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.shopItemDetailModel.notes = self.textAreaNotes.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resetButton(_ button: ProcessingButton) {
        if let img = self.cachedImageNormal {
            button.setImage(img, for: .normal)
        }
        self.cachedImageNormal = nil
        if let imgSel = self.cachedImageSel {
            button.setImage(imgSel, for: .selected)
        }
        self.cachedImageSel = nil
    }
    
    func updateRemindMeTitle() {
        self.viewOverlayReminder?.isHidden = self.shopItemDetailModel.dueDate != nil
        if let remider = self.shopItemDetailModel?.remindValue, self.shopItemDetailModel.dueDate != nil {
            var remindTime = "\(remider.reminderBeforeValue) \(remider.reminderBeforeUnit) before "
            remindTime += remider.readReminderTimeString()
            self.labelRemindMe.text = remindTime
            self.buttonRemoveReminder.isHidden = false
            self.imageViewReminderSideArrow?.isHidden = true
            return
        }
        self.labelRemindMe.text = Strings.chooseRemindType
        self.buttonRemoveReminder.isHidden = true
        self.imageViewReminderSideArrow?.isHidden = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.pageControlAttachment.currentPage = page
    }
    
    func updateAttachmentCollection() {
        self.collectionViewAttachments.reloadData()
        self.pageControlAttachment.numberOfPages = self.shopItemDetailModel.attachments.count
        self.viewAddAttachment.isHidden = !self.shopItemDetailModel.attachments.isEmpty
        self.pageControlAttachment.isHidden = self.shopItemDetailModel.attachments.count <= 1
    }
}
