//
//  ShopItemListCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol ShopItemListCellDelegate: class {
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, completion flag: Bool, indexPath: IndexPath)
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, didSelect indexPath: IndexPath)
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, checkBoxSelect indexPath: IndexPath)
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, shopListOn indexPath: IndexPath, quantity: String)
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, ShouldBeginEditing indexPath: IndexPath)
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, showAttachment indexPath: IndexPath)
}

class ShopItemListCell: UITableViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: ShopItemListCellDelegate?
    var planItShopListItem: PlanItShopListItems!
    var shopListItem: ShopListItemCellModel!
    var disableQuantityUpdate: Bool = false
    
    @IBOutlet weak var buttonSelection: UIButton?
    @IBOutlet weak var buttonCompletion: UIButton!
    @IBOutlet weak var textfieldShopItemName: NormalSpeechTextField?
    @IBOutlet weak var textfieldQuantity: UITextField?
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var labelCategoryName: UILabel?
    @IBOutlet weak var viewItemImage: UIView?
    @IBOutlet weak var imageViewItem: UIImageView?
    @IBOutlet weak var imageViewDate: UIImageView?
    @IBOutlet weak var labelDueDate: UILabel?
    @IBOutlet weak var viewDueDate: UIView?
    @IBOutlet weak var imageViewCompletedProfile: UIImageView?
    @IBOutlet weak var buttonCellSelect: UIButton?
    @IBOutlet weak var imageViewAttachment: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.imageViewCompletedProfile?.isHidden = true
        self.imageViewAttachment?.isHidden = true
        self.disableQuantityUpdate = false
        self.stopGradientAnimation()
        self.removeLongPressGesture()
    }
    
    func removeLongPressGesture() {
        if let gestures = self.buttonCellSelect?.gestureRecognizers {
            for gesture in gestures {
               if let recognizer = gesture as? UILongPressGestureRecognizer {
                    self.buttonCellSelect?.removeGestureRecognizer(recognizer)
               }
            }
        }
    }
    
    fileprivate func cellCommonConguration(index: IndexPath, shopListItem: ShopListItemCellModel, editMode: ShopListMode = .default) {
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
        self.buttonCellSelect?.addGestureRecognizer(longGesture)
        
        self.shopListItem = shopListItem
        self.indexPath = index
        self.buttonSelection?.isHidden = editMode == .default
        self.buttonSelection?.isSelected = shopListItem.editSelected
        self.buttonCompletion.isHidden = editMode == .edit
        self.planItShopListItem = shopListItem.planItShopListItem
        self.buttonCompletion.isSelected = shopListItem.planItShopListItem.isCompletedLocal
        self.textfieldShopItemName?.text = shopListItem.shopItem?.readItemName()
        self.textfieldQuantity?.text = shopListItem.planItShopListItem.quantity
        if shopListItem.planItShopListItem.isShopCustomItem {
            let mainCategoryName = (shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty)
            self.labelCategoryName?.text = !(shopListItem.shopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? shopListItem.shopItem?.readUserCategoryName() : (mainCategoryName.isEmpty ? "Others" : mainCategoryName)
        }
        else {
            let masterCategory = shopListItem.shopItem?.readMasterCategoryName() ?? Strings.empty
            self.labelCategoryName?.text = !masterCategory.isEmpty ? masterCategory : "Others"
        }
        if let shopItem = shopListItem.shopItem {
            self.imageViewItem?.isHidden = false
            self.imageViewItem?.pinImageFromURL(URL(string: shopItem.readImageName()), placeholderImage: UIImage(named: Strings.defaultShopItemImage))
        }
        let dueDate = shopListItem.planItShopListItem.readDueDateString()
        self.labelDueDate?.text = dueDate.isEmpty  ? Strings.empty : dueDate
        self.viewDueDate?.isHidden = dueDate.isEmpty
        self.imageViewAttachment?.isHidden = shopListItem.planItShopListItem.readAttachments().isEmpty
    }
    
    func configCell(_ index: IndexPath, shopListItem: ShopListItemCellModel, editMode: ShopListMode, delegate: ShopItemListCellDelegate) {
        self.cellCommonConguration(index: index, shopListItem: shopListItem, editMode: editMode)
        self.delegate = delegate
    }
    
    func configCompletedCell(index: IndexPath, shopListItem: ShopListItemCellModel, delegate: ShopItemListCellDelegate) {
        self.cellCommonConguration(index: index, shopListItem: shopListItem)
        self.delegate = delegate
        if shopListItem.planItShopListItem.isCompletedLocal {
            self.viewDueDate?.isHidden = false
            self.labelDueDate?.text = shopListItem.planItShopListItem.readCompletedDateString()
            if let modifieUser = shopListItem.planItShopListItem.modifiedBy {
                self.imageViewCompletedProfile?.isHidden = false
                self.imageViewCompletedProfile?.pinImageFromURL(URL(string: modifieUser.readValueOfProfileImage()), placeholderImage: modifieUser.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    @IBAction func checkBoxSelected(_ sender: UIButton) {
        self.delegate?.shopItemListCell(self, checkBoxSelect: self.indexPath)
    }
    
    @IBAction func itemSelected(_ sender: UIButton) {
        self.delegate?.shopItemListCell(self, didSelect: self.indexPath)
    }
    
    @IBAction func completedShopItemClicked(_ sender: UIButton) {
        self.delegate?.shopItemListCell(self, completion: !self.buttonCompletion.isSelected, indexPath: self.indexPath)
    }
    
    @objc func long(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            self.delegate?.shopItemListCell(self, showAttachment: self.indexPath)
        }
    }
    
    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
    }
    
}

extension ShopItemListCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.shopItemListCell(self, ShouldBeginEditing: self.indexPath)
        textField.returnKeyType = .default
        textField.reloadInputViews()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let savedQuantity = self.planItShopListItem.quantity
        if let entireQuantity = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !entireQuantity.isEmpty && (savedQuantity != entireQuantity || savedQuantity == nil) {
                self.delegate?.shopItemListCell(self, shopListOn: self.indexPath, quantity: entireQuantity)
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.disableQuantityUpdate { return }
        let savedQuantity = self.planItShopListItem.quantity
        if let entireQuantity = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !entireQuantity.isEmpty && (savedQuantity != entireQuantity || savedQuantity == nil) {
                self.delegate?.shopItemListCell(self, shopListOn: self.indexPath, quantity: entireQuantity)
            }
        }
    }
}
