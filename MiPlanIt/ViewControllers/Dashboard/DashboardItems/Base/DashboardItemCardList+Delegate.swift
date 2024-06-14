//
//  DashboardItemDetailList+Delegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardItemCardList: DashBoardCardViewCellDelegate {
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, openOverDue card: CardView) {
         self.itemDetailDelegate?.dashboardItemCardList(self, openOverDue: card)
    }
    
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, expandCard card: CardView) {
         self.itemDetailDelegate?.dashboardItemCardList(self, expandCard: card)
    }
    
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, selectedItem: Any) {
        self.itemDetailDelegate?.dashboardItemCardList(self, selectedItem: selectedItem)
    }
    
}
 
