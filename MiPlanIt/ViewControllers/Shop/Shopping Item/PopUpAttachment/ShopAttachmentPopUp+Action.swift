//
//  ShopAttachmentPopUp+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension ShopAttachmentPopUp {
    
    func showOrHidePopUpOptions(_ show: Bool) {
        self.constraintViewContainer.constant = show ? 45 : UIScreen.main.bounds.size.height
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor.black.withAlphaComponent(0.1).cgColor
        let colorBottom = UIColor.black.withAlphaComponent(1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.viewGradient.bounds
                
        self.viewGradient.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func setData() {
        self.pageControl.numberOfPages = self.shopListItemCellModel.planItShopListItem.readAttachments().count
        self.labelItemName.text = self.shopListItemCellModel.shopItem?.readItemName()
        if let shopItem = self.shopListItemCellModel.shopItem {
            self.imageViewItemImage?.pinImageFromURL(URL(string: shopItem.readImageName()), placeholderImage: UIImage(named: Strings.defaultShopItemImage))
        }
        self.textViewNotes.text = self.shopListItemCellModel.planItShopListItem.readNotes()
        self.pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.dismissView()
    }
    
    func dismissView() {
        self.showOrHidePopUpOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
