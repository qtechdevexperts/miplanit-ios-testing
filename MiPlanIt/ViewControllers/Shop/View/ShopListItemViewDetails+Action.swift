//
//  ShopListItemViewDetails+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShopListItemViewDetails {
    
    func initializeData() {
        self.datePicker.minimumDate = Date()
        self.textfieldQuantityCount.text = self.shopItemDetailModel.quantity
        if !self.shopItemDetailModel.categoryName.isEmpty {
            self.labelCategoryName.text = self.shopItemDetailModel.categoryName
        }
        self.textViewItemName.text = self.shopItemDetailModel.itemName
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
        self.buttonCheckMarkAsComplete?.isSelected = self.shopItemDetailModel.isCompleted
        self.showTagsCount()
        self.showAttachmentsCount()
        self.updateDueDate(date: self.shopItemDetailModel.dueDate)
        self.updateRemindMeTitle()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func showTagsCount() {
        self.labelShoppingTagCount.text = "\(self.shopItemDetailModel.tags.count)"
        self.labelShoppingTagCount.isHidden = self.shopItemDetailModel.tags.isEmpty
    }
    
    func showAttachmentsCount() {
        self.labelAttachmentCount.text = "\(self.shopItemDetailModel.attachments.count)"
        self.labelAttachmentCount.isHidden = self.shopItemDetailModel.attachments.isEmpty
    }
    
    func updateDueDate(date: Date?) {
        guard let dueDate = date else {
            self.shopItemDetailModel.dueDate = nil
            return
        }
        self.shopItemDetailModel.dueDate = dueDate
        self.labelDueDate.text = "Due " + (self.shopItemDetailModel.dueDate ?? Date()).stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.datePicker.date = (self.shopItemDetailModel.dueDate ?? Date())
        self.labelDueDate.textColor = .white
        self.buttonRemoveDueDate.isHidden = false
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
}
