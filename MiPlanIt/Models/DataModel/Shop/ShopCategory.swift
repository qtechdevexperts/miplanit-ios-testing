//
//  ShopCategory.swift
//  MiPlanIt
//
//  Created by Arun on 12/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopCategory {
    var shop = Strings.empty
    var prodCatId: Double = 1
    var prodCatName = Strings.empty
    var mainProducts: [ShopProduct] = []
    var deletedProducts: [ShopProduct] = []
    var completedProducts: [ShopProduct] = []
    
    init(with category: String, product: String, shop: String) {
        self.shop = shop
        self.prodCatName = category
        self.addProduct(product)
    }
    
    
    
    func addProduct(_ product: String) {
        self.mainProducts.append(ShopProduct(with: product, category: self.prodCatId))
    }
    
    func addProduct(_ product: PlanItShopItems) {
        self.mainProducts.insert(ShopProduct(with: product, category: self.prodCatId), at: 0)
    }
    
    func removeProductAtIndex(_ index: Int) -> ShopProduct {
        let product = self.mainProducts[index]
        self.mainProducts.remove(at: index)
        if product.itemId != 0 && !self.shop.isEmpty {
            self.deletedProducts.append(product)
        }
        return product
    }
    
    func completeProductAtIndex(_ index: Int) -> ShopProduct {
        let product = self.mainProducts[index]
        self.mainProducts.remove(at: index)
        if product.itemId != 0 && !self.shop.isEmpty {
            self.completedProducts.append(product)
        }
        return product
    }
    
    func isValidProduct(_ index: Int) -> Bool {
        return !self.mainProducts[index].itemName.isEmpty
    }
    
    func removePreductFromCompletedList(_ product: ShopProduct) {
        self.mainProducts.append(product)
        self.completedProducts.removeAll(where: { return $0 == product })
    }
    
    func removePreductFromDeletedList(_ product: ShopProduct) {
        self.mainProducts.append(product)
        self.deletedProducts.removeAll(where: { return $0 == product })
    }
}
