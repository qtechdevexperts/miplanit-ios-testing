//
//  CreateNewListViewController+Action.swift
//  MiPlanIt
//
//  Created by fsadsmin on 24/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension CreateNewListViewController {
    
    func initialiseUIComponents() {
        self.initialiseShoppingListImageColor()
        self.textFieldShoppingListName.text = Strings.empty
        self.imageViewShoppingListImage.image = #imageLiteral(resourceName: "defaultshoppingcategoryicon")
        if !self.shop.shopId.isEmpty {
            self.textFieldShoppingListName.text = self.shop.shopListName
            self.setCalendarImageColor()
        }
        else if let defaultColor = self.viewShoppingListBGColor.getDefaultColot(){
            self.updateBGWithColor(defaultColor.colorCode.readColorCodeKey())
        }
    }
    
    func setCalendarImageColor() {
        if self.shop.shopImageName.isEmpty {
            self.imageViewShoppingListImage.image = #imageLiteral(resourceName: "defaultshoppingcategoryicon")
        }
        else {
            if let imageData = self.shop.shopListImageData {
                self.imageViewShoppingListImage.image =  UIImage(data: imageData)
            }
            else {
                self.imageViewShoppingListImage.pinImageFromURL(URL(string: self.shop.shopImageName), placeholderImage: UIImage(named: Strings.defaultshoppingcategoryicon))
            }
        }
        self.viewShoppingListBGColor.setSelectionForColor(colorCode: self.shop.shopColorCode)
        self.updateBGWithColor(self.shop.shopColorCode)
    }
    
    func validShopList() -> Bool {
        let trimmedName = self.shop.shopListName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
    }
    
    func hasDuplicateShopListName() -> Bool {
        let trimmedName = self.shop.shopListName.trimmingCharacters(in: .whitespacesAndNewlines)
        if DatabasePlanItShopList().readSpecificShopByName(trimmedName, exceptId: Double(self.shop.shopId) ?? 0.0).first != nil {
            return true
        }
        return false
    }
    
    func updateBGWithColor(_ color: String) {
        self.shop.shopColorCode = color
        let color = self.getShoppingListBGColor(color)
        self.viewShoppingListBG.backgroundColor = color.withAlphaComponent(0.4)
        self.viewImageHolder.backgroundColor = color
    }
    
    func initialiseShoppingListImageColor() {
        self.arrayShoppingListImageViews.forEach { (view) in
            view.buttonImage.isSelected = false
            view.delegate = self
        }
        self.viewShoppingListBGColor.delegate = self
    }
    
    func getShoppingListBGColor(_ colorCode: String?) -> UIColor {
        if let color = colorCode, !color.isEmpty {
            let colorRGB = color.components(separatedBy: " ")
            if colorRGB.count == 3 {
                let red = Double(colorRGB[0])
                let green = Double(colorRGB[1])
                let blue = Double(colorRGB[2])
                return UIColor.init(red: CGFloat(red!) / 255.0, green: CGFloat(green!) / 255.0, blue: CGFloat(blue!) / 255.0, alpha: 1)
            }
        }
        return UIColor.init(red: 239/255.0, green: 247/255.0, blue: 255/255.0, alpha: 1)
    }

}
