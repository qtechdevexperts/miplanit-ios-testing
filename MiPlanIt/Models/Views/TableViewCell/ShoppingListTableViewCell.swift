//
//  PurchaseListTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol ShoppingListTableViewCellDelegate: class {
    func ShoppingListTableViewCell(_ shoppingListTableViewCell: ShoppingListTableViewCell, shopList: PlanItShopList)
}

class ShoppingListTableViewCell: UITableViewCell {
    
    var shopList: PlanItShopList!
    weak var delegate: ShoppingListTableViewCellDelegate?
        
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var labelShopListName: UILabel!
    @IBOutlet weak var imageViewShopList: UIImageView!
    @IBOutlet weak var viewShopListColor: UIView!
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var labelShopListItemCount: UILabel!
    @IBOutlet weak var viewAssignee: UIView!
    @IBOutlet weak var imageViewAssignee: UIImageView!
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        self.delegate?.ShoppingListTableViewCell(self, shopList: self.shopList)
    }
    
    func setAssigneOrSharedUser(shopList: PlanItShopList) {
        if let creator = shopList.createdBy, creator.readValueOfUserId() != Session.shared.readUserId() {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    func configCell(planItShopList: PlanItShopList, delegate: ShoppingListTableViewCellDelegate) {
        self.shopList = planItShopList
        self.delegate = delegate
        self.labelShopListName.text = planItShopList.readShopListName()
        self.buttonShare.isHidden = planItShopList.readAllOtherUser().filter({ $0.readResponseStatus() != .eRejected }).isEmpty
        self.viewShopListColor.backgroundColor = planItShopList.readShopListColor().getColor()
        if let imageData = planItShopList.shopListImageData {
            self.imageViewShopList.image = UIImage(data: imageData)
        }
        else {
            self.imageViewShopList.pinImageFromURL(URL(string: planItShopList.readShopListImage()), placeholderImage: UIImage(named: Strings.defaultshoppingcategoryicon))
        }
        self.imageViewShopList.contentMode = .scaleAspectFit
        self.viewAssignee.isHidden = true
        let count = planItShopList.readAllInCompleteShopListItems().count
        self.labelShopListItemCount.isHidden = count == 0
        self.labelShopListItemCount.text = "\(count)"
        self.setAssigneOrSharedUser(shopList: planItShopList)
    }
    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
