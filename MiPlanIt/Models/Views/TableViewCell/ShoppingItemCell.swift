//
//  ShoppingItemCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShoppingItemCellDelegate: class {
    func shoppingItemCell(_ shoppingItemCell: ShoppingItemCell, onDelete index: IndexPath)
    func shoppingItemCell(_ shoppingItemCell: ShoppingItemCell, onComplete index: IndexPath)
    func shoppingItemCell(_ shoppingItemCell: ShoppingItemCell, onTextUpdate textField: UITextField)
    func shoppingItemCell(_ shoppingItemCell: ShoppingItemCell, textFieldDidBeginEditing textField: UITextField)
    func shoppingItemCell(_ shoppingItemCell: ShoppingItemCell, textFieldDidEndEditing textField: UITextField)
}

class ShoppingItemCell: UITableViewCell {
    
    var index: IndexPath!
    var product: ShopProduct!
    weak var delegate: ShoppingItemCellDelegate?
    var completedStatus = false
    @IBOutlet weak var txtItemName: FloatingTextField!
    @IBOutlet weak var txtQuantity: FloatingTextField!
    @IBOutlet weak var buttonComplete: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var constraintCompleteButtonWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureProduct(_ product: ShopProduct, under category: ShopCategory, status: Bool, at indexPath: IndexPath, delegate: ShoppingItemCellDelegate) {
        self.product = product
        self.index = indexPath
        self.delegate = delegate
        self.txtItemName.text = product.itemName
        self.txtQuantity.text = product.quantity
        self.txtItemName.isUserInteractionEnabled = product.itemId == 0
        self.completedStatus = status
        self.constraintCompleteButtonWidth.constant = category.shop.isEmpty ? 0 : 35
    }
    
    @IBAction func checkBoxButtonClicked(_ sender: UIButton) {
        guard !self.completedStatus else {
            return
        }
        self.delegate?.shoppingItemCell(self, onComplete: self.index)
    }
    
    @IBAction func deleteItemButtonClicked(_ sender: UIButton) {
        guard !self.completedStatus else {
            return
        }
        self.delegate?.shoppingItemCell(self, onDelete: self.index)
    }
    
    @IBAction func itemNameOnChange(_ sender: UITextField) {
        self.delegate?.shoppingItemCell(self, onTextUpdate: sender)
    }
}

extension ShoppingItemCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField {
        case self.txtItemName:
            self.product.itemName  = textField.text ?? Strings.empty
            self.delegate?.shoppingItemCell(self, textFieldDidEndEditing: textField)
        case self.txtQuantity:
            self.product.quantity  = textField.text ?? Strings.empty
        default: break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtItemName {
            self.delegate?.shoppingItemCell(self, textFieldDidBeginEditing: textField)
        }
    }
}
