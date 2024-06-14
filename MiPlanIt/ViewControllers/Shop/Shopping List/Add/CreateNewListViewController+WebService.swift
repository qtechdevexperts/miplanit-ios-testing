//
//  CreateNewListViewController+WebService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateNewListViewController {
    
    func addShopping() {
        self.buttonSave.startAnimation()
        ShopService().addShopList(self.shop) { (response, error) in
            if let result = response {
                self.createServiceToUploadCalendarImages(planItShopList: result)
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    
    func createServiceToUploadCalendarImages(planItShopList: PlanItShopList) {
        let fileName = String(Date().millisecondsSince1970) + Extensions.png
        guard let user = Session.shared.readUser(), let image = self.imageViewShoppingListImage.image, let data = image.jpegData(compressionQuality: 0.5) else {
            self.showSuccessAlertOfCalendar(planItShopList: planItShopList)
            return
        }
        ShopService().uploadShopListImages(planItShopList, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName, by: user) { (result, error) in
            if result {
                self.showSuccessAlertOfCalendar(planItShopList: planItShopList)
            }
            else {
                self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    //MARK: - Tick Animation
                    self.showAlertWithAction(message: Message.calendarImageUploadFailed, title: Message.error, items: [Message.ok], callback: { _ in
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.createNewListViewController(self, createdUpdatedShoppingList: planItShopList)
                    })
                }
            }
        }
    }
    
    func showSuccessAlertOfCalendar(planItShopList: PlanItShopList) {
        self.buttonSave.clearButtonTitleForAnimation()
        self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
            self.buttonSave.showTickAnimation(borderOnly: true, completion: { (results) in
                self.dismiss(animated: true) {
                    self.delegate?.createNewListViewController(self, createdUpdatedShoppingList: planItShopList)
                }
            })
        }
    }
}
