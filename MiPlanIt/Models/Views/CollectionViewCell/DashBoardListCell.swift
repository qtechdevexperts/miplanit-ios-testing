//
//  DashBoardListCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol DashBoardListCellDelegate: class {
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, selectedItem: Any)
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, todayButtonClickedIndex: Int?)
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, overdueButtonClickedIndex: Int?)
}

class DashBoardListCell: UICollectionViewCell {
    
    weak var delegate: DashBoardListCellDelegate?
    
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var viewCountContainer: UIView!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var viewList: DashBoardItemListView!
    @IBOutlet weak var labelNoItem: UILabel?
    @IBOutlet weak var labelSection: UILabel!
    @IBOutlet weak var buttonForToday: UIButton!
    @IBOutlet weak var buttonForTodayOnCount: UIButton!
    @IBOutlet weak var buttonForImage: UIButton!
    @IBOutlet weak var viewOverdue: UIView!
    @IBOutlet weak var viewToday: UIView!
    
    var bgColor1: UIColor?
    var bgColor2: UIColor?
    var labelColor: UIColor?
    @IBOutlet weak var buttonForOverdue: UIButton!
    @IBOutlet weak var labelForOverdueCount: UILabel!
    
    //MARK: - IBActions
    @IBAction func overdueCountButtonClicked(_ sender: UIButton) {
        self.delegate?.dashBoardListCell(self, overdueButtonClickedIndex: self.viewList?.collectionViewRowIndex)
    }
    @IBAction func todayButtonClicked(_ sender: Any) {
        self.delegate?.dashBoardListCell(self, todayButtonClickedIndex: self.viewList?.collectionViewRowIndex)
    }
    
    override func prepareForReuse() {
        self.labelSection.isHidden = false
    }
    
    func configCell(indexPath: Int, dashBoardItem: DashboardItems, section: DashBoardSection, delegate: DashBoardListCellDelegate, isCustomDashboard: Bool, overDue: Int) {
        self.viewList.isCustomDashboard = isCustomDashboard
        self.viewList.dateSection = section
        self.viewList.dashBordItem = dashBoardItem
        self.viewList.collectionViewRowIndex = indexPath
        var labelType: String = Strings.empty
        let allDashboardCards = Storage().getAllDashboardCards()
        self.viewList.bordorWidth = 2
        var iconName = "eventIconnew"
        self.viewOverdue.isHidden = true
        switch indexPath {
        case 0:
            labelType = "Events"
            self.labelNoItem?.text = Message.noItemsFound
            if let dashboardCard = allDashboardCards.filter({ $0.dashBoardTitle == .event }).first {
                bgColor1 = dashboardCard.bgColorCode.getColor()
                bgColor2 = dashboardCard.bgColorCode2.getColor()
                labelColor = dashboardCard.titleColor.getColor()
                self.viewCountContainer.backgroundColor = dashboardCard.bgColorCodeCount.getColorWithOpacity()
                self.viewCountContainer.bordorColor = dashboardCard.borderColorCodeCount.getColor()
                self.viewList.bordorColor = dashboardCard.borderColorCode.getColor()
                iconName = "eventIconnew"
            }
        case 1:
            labelType = "To Do"
            self.viewOverdue.isHidden = overDue != 0 ? false : true
            self.labelForOverdueCount.text = overDue > 99 ? "99+" : "\(overDue)"
            self.labelNoItem?.text = Message.noItemsFound
            if let dashboardCard = allDashboardCards.filter({ $0.dashBoardTitle == .toDo }).first {
                bgColor1 = dashboardCard.bgColorCode.getColor()
                bgColor2 = dashboardCard.bgColorCode2.getColor()
                labelColor = dashboardCard.titleColor.getColor()
                self.viewCountContainer.backgroundColor = dashboardCard.bgColorCodeCount.getColorWithOpacity()
                self.viewCountContainer.bordorColor = dashboardCard.borderColorCodeCount.getColor()
                self.viewList.bordorColor = dashboardCard.borderColorCode.getColor()
                iconName = "todoIconnew"
            }
        case 2:
            labelType = "Shopping"
            self.labelNoItem?.text = Message.noItemsFound
            if let dashboardCard = allDashboardCards.filter({ $0.dashBoardTitle == .shopping }).first {
                bgColor1 = dashboardCard.bgColorCode.getColor()
                bgColor2 = dashboardCard.bgColorCode2.getColor()
                labelColor = dashboardCard.titleColor.getColor()
//                self.viewCountContainer.backgroundColor = dashboardCard.bgColorCodeCount.getColorWithOpacity()
                self.viewCountContainer.backgroundColor = .white.withAlphaComponent(0.8)
                self.viewCountContainer.bordorColor = dashboardCard.borderColorCodeCount.getColor()
                self.viewList.bordorColor = dashboardCard.borderColorCode.getColor()
                iconName = "shoppingIconnew"
            }
        case 3:
            labelType = "Coupons & Gifts"
            self.labelNoItem?.text = Message.noItemsFound
            if let dashboardCard = allDashboardCards.filter({ $0.dashBoardTitle == .giftCard }).first {
                bgColor1 = dashboardCard.bgColorCode.getColor()
                bgColor2 = dashboardCard.bgColorCode2.getColor()
                labelColor = dashboardCard.titleColor.getColor()
                self.viewCountContainer.backgroundColor = dashboardCard.bgColorCodeCount.getColorWithOpacity()
                self.viewCountContainer.bordorColor = dashboardCard.borderColorCodeCount.getColor()
                self.viewList.bordorColor = dashboardCard.borderColorCode.getColor()
                iconName = "giftCardIconnew"
            }
        default:
            labelType = "Receipts & Bills"
            self.labelNoItem?.text = Message.noItemsFound
            if let dashboardCard = allDashboardCards.filter({ $0.dashBoardTitle == .purchase }).first {
                bgColor1 = dashboardCard.bgColorCode.getColor()
                bgColor2 = dashboardCard.bgColorCode2.getColor()
                labelColor = dashboardCard.titleColor.getColor()
                self.viewCountContainer.backgroundColor = dashboardCard.bgColorCodeCount.getColorWithOpacity()
                self.viewCountContainer.bordorColor = dashboardCard.borderColorCodeCount.getColor()
                self.viewList.bordorColor = dashboardCard.borderColorCode.getColor()
                iconName = "purchaseIconNew"
            }
        }
        self.buttonForImage.setImage(UIImage(named: iconName), for: .normal)
        self.labelType.text = labelType
        let count = dashBoardItem.items.count > 99 ? "99+" : "\(dashBoardItem.items.count)"
        self.labelCount.text = count
        self.viewList.delegate = self
        self.delegate = delegate
        self.labelNoItem?.isHidden = !dashBoardItem.items.isEmpty
        self.buttonForToday.isHidden = true
        buttonForTodayOnCount.isHidden = true
        switch section {
        case .today:
            self.labelSection.text = "Today"
            if indexPath == 1 {
                self.buttonForToday.isHidden = false
                buttonForTodayOnCount.isHidden = false
            }
        case .tomorrow:
            self.labelSection.text = "Tomorrow"
        case .week:
            self.labelSection.text = "This Week"
        default:
            self.labelSection.text = "Upcoming"
        }
        self.layoutIfNeeded()
        self.updateBgGradient(color1: bgColor1, color2: bgColor2, labelColour: labelColor)
    }
    func updateBgGradient(color1 : UIColor?, color2 : UIColor?, labelColour: UIColor?) {
        if let colour1 = color1, let colour2 = color2, let color3 = labelColour {
            self.viewList.viewBG.createGradientLayer(colours: [colour1, colour2], locations: nil,startPOint: CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint(x: 0.5, y: 1.0))
            self.labelCount.textColor = .black//color3
            self.labelType.textColor = color3
            self.labelSection.textColor = color3
        }
    }
}

extension DashBoardListCell: DashBoardItemListViewDelegate {
    
    func dashBoardItemListView(_ DashBoardView: DashBoardItemListView, selectedItem: Any) {
        self.delegate?.dashBoardListCell(self, selectedItem: selectedItem)
    }
}
