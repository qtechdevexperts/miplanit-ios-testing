//
//  ShareLinkFilterViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ShareLinkFilterViewController {
    
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.active, type: .eActive, isNeedImage: false, isSelected: self.selectedFilter == .eActive, imageName: FileNames.todoIcon), DropDownItem(name: Strings.expired, type: .eExpired, isNeedImage: false, isSelected: self.selectedFilter == .eExpired, imageName: FileNames.shoppingIcon)]
    }
    
    func updateResetButtonStatus() {
        self.buttonResetFilter.isSelected = self.selectedFilter != nil
        self.buttonResetFilter.backgroundColor = self.selectedFilter == nil ? UIColor.clear : UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1)
    }
}
