//
//  CreateEventsViewController+EventTagDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddGiftCouponsViewController: GiftCouponTagCollectionViewCellDelegate {
    
    func giftCouponTagCollectionViewCell(_ cell: GiftCouponTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath) {
        self.giftCouponModel.removeTagAtIndex(indexPath.row)
        self.updateTagCollectionViewHeight()
    }
}

extension AddGiftCouponsViewController: GiftCouponAddTagCollectionViewCellDelegate {

    func giftCouponAddTagCollectionViewCell(_ cell: GiftCouponAddTagCollectionViewCell, checkExisting tag: String) -> Bool {
        return self.giftCouponModel.tags.contains(where: {$0.caseInsensitiveCompare(tag) == .orderedSame})
    }

    func giftCouponAddTagCollectionViewCell(_ cell: GiftCouponAddTagCollectionViewCell, addedNewTag tag: String) {
        self.giftCouponModel.addTag(tag)
        self.updateTagCollectionViewHeight()
    }
}

extension AddGiftCouponsViewController: AttachmentListViewControllerDelegate {
    
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment]) {
        self.giftCouponModel.attachments = items
        self.showAttachmentsCount()
    }
}

extension AddGiftCouponsViewController: AddGiftTagViewControllerDelegate {
    
    func addGiftTagViewController(_ viewController: AddGiftTagViewController, updated tags: [String]) {
        self.giftCouponModel.tags = tags
        self.showTagsCount()
    }
}

extension AddGiftCouponsViewController: GiftTypeDropDownViewControllerDelegate {
    func giftTypeDropDownViewController(_ controller: GiftTypeDropDownViewController, selectedOption: DropDownItem) {
        self.setGiftCategoryName(selectedOption.title)
        switch selectedOption.dropDownType {
        case .eCouponTypeGift:
            self.giftCouponModel.setCouponDataType(.gift)
        case .eCouponTypeCoupon:
            self.giftCouponModel.setCouponDataType(.coupon)
        default:
            break
        }
    }
}

extension AddGiftCouponsViewController: CurrencyCodeViewControllerDelegate {
    
    func currencyCodeViewController(_ controller: CurrencyCodeViewController, selectedOption: String) {
        self.giftCouponModel.currencySymbol = selectedOption.getLocalCurrencySymbol()
        self.buttonCurrencySymbol.setTitle(self.giftCouponModel.currencySymbol, for: .normal)
        self.txtfldAmount.placeholder = "Amount (\(self.giftCouponModel.currencySymbol))"
    }
}

