//
//  SearchAllShopItemViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension SearchAllShopItemViewController {
    
    func createWebServiceToAddNewShopListItem(_ details: ShopListItemDetailModel) {
        self.viewQuantityOption.startPlusButtonAnimation()
        ShopService().updateShopListDetail(details) { (result, error) in
            self.viewQuantityOption.stopPlusButtonAnimation(with: result) { (status) in
                if status {
                    self.delegate?.searchAllShopItemViewController(self, addedNewItem: details)
                    self.shopAllItems = self.getAllShopListItem()
                    self.filterShopListItemWithText(self.viewQuantityOption.textField.text ?? Strings.empty)
                }
                else {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
}
