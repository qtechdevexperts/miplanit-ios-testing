//
//  DashBoardListMainViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashBoardListMainViewController: DashBoardListCellDelegate {
    
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, selectedItem: Any) {
        self.dismiss(animated: true) {
            self.delegate?.dashBoardListMainViewController(self, selectedItem: selectedItem)
        }
    }
    
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, overdueButtonClickedIndex: Int?) {
        self.dismiss(animated: true) {
            self.delegate?.dashBoardListMainViewController(self, toDoOverdue: self.overDueToDo)
        }
    }
    
    func dashBoardListCell(_ dashBoardListCell: DashBoardListCell, todayButtonClickedIndex: Int?) {
        self.dismiss(animated: true) {
            guard let index = todayButtonClickedIndex else { return }
            self.delegate?.dashBoardListMainViewController(self, toDoToday: self.dashboardItems[index].items)
        }
    }
    
}
