//
//  ShopMasterItemCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShopMasterItemCellDelegate: class {
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, addQuantity: String)
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, onEdit: IndexPath)
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, customQuantity: String)
}

class ShopMasterItemCell: UICollectionViewCell {
    
    var index: IndexPath!
    weak var delegate: ShopMasterItemCellDelegate?
    var shoppingListOptionType: ShoppingListOptionType = .categories
    
    @IBOutlet weak var imageViewItem: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var textFieldQuantity: UITextField!
    
    @IBAction func quantityChanged(_ sender: UITextField) {
        self.delegate?.shopMasterItemCell(self, customQuantity: sender.text ?? Strings.empty)
    }
    
    
    func configCell(index: IndexPath, masterItem: ShopItem, delegate: ShopMasterItemCellDelegate) {
        self.index = index
        self.delegate = delegate
        self.labelItemName.text = masterItem.itemName
        if let planItShopItem = masterItem.planItShopItem {
            self.imageViewItem.pinImageFromURL(URL(string: planItShopItem.readImageName()), placeholderImage: UIImage(named: Strings.defaultShopItemImage))
        }
        self.viewContainer.bordorColor = masterItem.itemSelected ? UIColor(red: 147/255, green: 204/255, blue: 214/255, alpha: 1.0) : UIColor.clear
        self.viewContainer.shadowColor = self.viewContainer.backgroundColor?.darker()
        self.textFieldQuantity.text = masterItem.quantity
        switch shoppingListOptionType {
        case .categories:
            if masterItem.itemSelected {
                self.addQuantity()
            }
        default:
            break
        }
    }
        
    func addQuantity() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            self.textFieldQuantity.becomeFirstResponder()
            self.delegate?.shopMasterItemCell(self, onEdit: self.index)
        }
    }
    
}

extension ShopMasterItemCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.shopMasterItemCell(self, addQuantity: (textField.text ?? Strings.empty))
        textField.endEditing(true)
        return true
    }
}
