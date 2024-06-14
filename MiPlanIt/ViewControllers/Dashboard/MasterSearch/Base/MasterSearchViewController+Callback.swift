//
//  MasterSearchViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MasterSearchViewController: SearchFilterDateViewControllerDelegate {
    
    func searchFilterDateViewController(_ searchFilterDateViewController: SearchFilterDateViewController, selectedStartDate: Date, selectedEndDate: Date) {
        self.updateSearchIndex()
        self.selectedFilterDate = selectedStartDate
        self.selectedFilterDateEnd = selectedEndDate
        self.buttonFilter.isSelected = true
        self.updateSearchByDate()
    }
    
    func searchFilterDateViewControllerClearDate(_ searchFilterDateViewController: SearchFilterDateViewController) {
        self.updateSearchIndex()
        self.selectedFilterDate = Date()
        self.selectedFilterDateEnd = Date().adding(years: 1)
        self.buttonFilter.isSelected = false
        self.updateSearchByDate()
    }
}

extension MasterSearchViewController: DashboardSearchSectionViewDelegate {
    
    func dashboardSearchSectionView(_ view: DashboardSearchSectionView, withSelectedOption option: DashboardSectionView) {
        guard let dashboardSection = option.dashboardSectionType else { return }
        self.activeSection = dashboardSection
    }
}
