//
//  DashboardCardViewShopListItemCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCardViewShopListItemCell: UITableViewCell {

    @IBOutlet weak var labelShopListItemName: UILabel!
    @IBOutlet weak var labelDueDate: UILabel!
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
        if let creator = shopItem.planItShopListItems?.shopList?.createdBy, creator.readValueOfUserId() != Session.shared.readUserId() {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    func configCell(shopListItem: DashboardShopListItem, index: IndexPath) {
        self.labelShopListItemName.text = shopListItem.itemName
        if let dueDate = shopListItem.actualDueDate {
            if dueDate.initialHour() == Date().initialHour() {
                self.labelDueDate.text = Strings.dashboardDueDate + "Today"
            }
            else {
                self.labelDueDate.text = Strings.dashboardDueDate + (dueDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY))
            }
        }
        self.labelShopListName.text = !shopListItem.shopListName.isEmpty ? " \(shopListItem.shopListName)" : Strings.empty
        self.viewAssignee.isHidden = true
        self.setAssigneOrSharedUser(shopItem: shopListItem)
    }

    
    //Previuos function
//    func configCell(shopListItem: DashboardShopListItem, index: IndexPath) {
//        self.labelShopListItemName.text = shopListItem.itemName
//        if let dueDate = shopListItem.actualDueDate {
//            if dueDate.initialHour() == Date().initialHour() {
//                self.labelDueDate.text = Strings.dashboardDueDate + "Today"
//            }
//            else {
//                self.labelDueDate.text = Strings.dashboardDueDate + (dueDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY))
//            }
//        }
//        self.labelShopListName.text = !shopListItem.shopListName.isEmpty ? ", \(shopListItem.shopListName)" : Strings.empty
//        self.viewAssignee.isHidden = true
//        self.setAssigneOrSharedUser(shopItem: shopListItem)
//    }
}
