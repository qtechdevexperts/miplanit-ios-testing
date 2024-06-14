//
//  ShopListItemDetailDashboardCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShopListItemDetailDashboardCell: UITableViewCell {

    var index: IndexPath!
    var redColorFont: UIColor = UIColor(red: 243/255, green: 119/255, blue: 91/255, alpha: 1.0)
    var normalColorFont: UIColor = UIColor(red: 118/255, green: 136/255, blue: 150/255, alpha: 1.0)
    
    @IBOutlet weak var labelShopListItemName: UILabel!
    @IBOutlet weak var labelShopListItemDueDate: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelShopListName: UILabel!
    @IBOutlet weak var imageViewshopList: UIImageView!
    @IBOutlet weak var viewAssignee: UIView!
    @IBOutlet weak var imageViewAssignee: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAssigneOrSharedUser(shopItem: DashboardShopListItem) {
        if let creator = shopItem.planItShopListItems?.shopList?.createdBy, creator.readValueOfUserId() != Session.shared.readUserId()  {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    func configCell(shopListItem: DashboardShopListItem, index: IndexPath) {
        self.index = index
        self.labelShopListItemName.text = shopListItem.itemName
        self.labelShopListItemDueDate.isHidden = shopListItem.actualDueDate == nil
        if let dueDate = shopListItem.actualDueDate {
            if dueDate.initialHour() == Date().initialHour() {
                self.labelShopListItemDueDate.text = Strings.dashboardDueDate + "Today"
            }
            else {
                self.labelShopListItemDueDate.text = Strings.dashboardDueDate + (dueDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY))
            }
        }
        self.labelShopListName.text = shopListItem.shopListName
        self.imageViewshopList.image = UIImage(named: Strings.defaultshoppingcategoryicon)
        if !shopListItem.shopListImage.isEmpty {
            self.imageViewshopList.pinImageFromURL(URL(string: shopListItem.shopListImage), placeholderImage:  UIImage(named: Strings.defaultshoppingcategoryicon))
        }
        self.viewAssignee.isHidden = true
        self.setAssigneOrSharedUser(shopItem: shopListItem)
    }

}
