//
//  MasterSearchViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension MasterSearchViewController: UITextFieldDelegate {
    
    func initialDateRangeSetUp() {
        self.selectedFilterDate = Date().initialHour()
        self.selectedFilterDateEnd = Date().initialHour().adding(years: 1)
        self.startDateOfMonth = self.selectedFilterDate
        self.endDateOfMonth = self.selectedFilterDateEnd
    }
    
    func initializeUI() {
        self.textfieldSearch.attributedPlaceholder = NSAttributedString(string: Strings.masterSearchPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        self.textfieldSearch.tintColor = .white
        self.showDateRange(startDate: self.selectedFilterDate, endDate: self.selectedFilterDateEnd)
        self.viewSearchSections.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func getSearchText() -> String {
        guard let text = self.textfieldSearch.text else { return Strings.empty }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    func chechSearchDataResult() {
        let sectionValues = self.masterSearchItems[self.getSelectedSectionValue()] ?? []
        self.imageViewNoResult.isHidden = !sectionValues.isEmpty
    }
    
    func checkResultAndReload() {
        self.chechSearchDataResult()
        self.tableView?.reloadData()
    }
    
    func updateSearchList(_ type: DashBoardTitle? = nil, forceReload: Bool = false) {
        DispatchQueue.main.async {
            let allExcludedSections = self.activeCustomDashboard?.readAllExcludedSections().compactMap({ $0.readSectionName() })
            let searchText = self.getSearchText()
            self.buttonCloseSearch.isHidden = searchText.isEmpty
            switch type {
            case .event:
                self.updateEventSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            case .toDo:
                self.updateToDoSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            case .purchase:
                self.updatePurchaseSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            case .giftCard:
                self.updateGiftSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            case .shopping:
                self.updateShoppingSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            case .none:
                self.updateEventSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
                self.updateToDoSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
                self.updatePurchaseSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
                self.updateGiftSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
                self.updateShoppingSearchList(searchText: searchText, allExcludedSections: allExcludedSections)
            }
            if let sectionType = type, self.activeSection == sectionType {
                self.checkResultAndReload()
            }
            else if forceReload {
                self.checkResultAndReload()
            }
        }
    }
    
    func updateEventSearchList(searchText: String, allExcludedSections: [String]?) {
        if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.event.rawValue }) {
            self.masterSearchItems[0] = []
            return
        }
        var events = self.filterEventWithDashboardTag(self.visibleEvents, on: self.activeCustomDashboard)
        if !self.getSearchText().isEmpty {
            events = events.filter({ $0.containsName(searchText) || $0.containsTags(searchText) || $0.containsDescription(searchText) })
        }
        self.masterSearchItems[0] = events.sorted(by: { (item1, item2) -> Bool in
            (item1.isAllDay ? item1.initialDate : item1.start) < (item2.isAllDay ? item2.initialDate : item2.start)
        })
    }
    
    func updateToDoSearchList(searchText: String = Strings.empty, allExcludedSections: [String]?) {
        if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.todo.rawValue }) {
            self.masterSearchItems[1] = []
            return
        }
        var todos = self.filterToDoWithDashboardTag(self.visibleTodos, on: self.activeCustomDashboard)
        if !self.getSearchText().isEmpty {
            todos = todos.filter({ $0.containsName(searchText) || $0.containsTags(searchText) || $0.containsDescription(searchText) })
        }
        let unPlannedTodos = todos.filter({ return $0.actualDate == nil }).sorted(by: { return $0.text < $1.text })
        let plannedTodos = todos.filter({ return $0.actualDate != nil }).sorted(by: { if let date1 = $0.actualDate, let date2 = $1.actualDate { return date1 < date2 } else { return false } })
        self.masterSearchItems[1] = unPlannedTodos + plannedTodos
    }
    
    func updatePurchaseSearchList(searchText: String = Strings.empty, allExcludedSections: [String]?) {
        if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.purchase.rawValue }) {
             self.masterSearchItems[4] = []
            return
        }
        var purchases = self.filterPurchaseWithDashboardTag(self.visiblePurchases, on: self.activeCustomDashboard)
        if !self.getSearchText().isEmpty {
            purchases = purchases.filter({ $0.containsName(searchText) || $0.containsTags(searchText) || $0.containsDescription(searchText) })
        }
        self.masterSearchItems[4] = purchases.sorted(by: { (item1, item2) -> Bool in
            item1.bilDateTime < item2.bilDateTime
        })
    }
    
    func updateShoppingSearchList(searchText: String = Strings.empty, allExcludedSections: [String]?) {
        if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.shopping.rawValue }) {
            self.masterSearchItems[2] = []
            return
        }
        var shopping = self.filterShopListItemWithDashboardTag(self.visibleShopings, on: self.activeCustomDashboard)
        if !self.getSearchText().isEmpty {
            shopping = shopping.filter({ $0.containsName(searchText) || $0.containsTags(searchText) || $0.containsDescription(searchText) || $0.containsCategory(searchText) })
        }
        let unPlannedShopping = shopping.filter({ return $0.actualDueDate == nil }).sorted(by: { return $0.itemName < $1.itemName })
        let plannedShopping = shopping.filter({ return $0.actualDueDate != nil }).sorted(by: { if let date1 = $0.actualDueDate, let date2 = $1.actualDueDate { return date1 < date2 } else { return false } })
        self.masterSearchItems[2] = unPlannedShopping + plannedShopping
    }
    
    func updateGiftSearchList(searchText: String = Strings.empty, allExcludedSections: [String]?) {
        if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.gift.rawValue }) {
            self.masterSearchItems[3] = []
            return
        }
        var gifts = self.filterGiftWithDashboardTag(self.visibleGifts, on: self.activeCustomDashboard)
        if !self.getSearchText().isEmpty {
            gifts = gifts.filter({ $0.containsName(searchText) || $0.containsTags(searchText) || $0.containsDescription(searchText) })
        }
        let unPlannedGift = gifts.filter({ return $0.exipryDate == nil }).sorted(by: { return $0.title < $1.title })
        let plannedGift = gifts.filter({ return $0.exipryDate != nil }).sorted(by: { if let date1 = $0.exipryDate, let date2 = $1.exipryDate { return date1 < date2 } else { return false } })        
        self.masterSearchItems[3] = unPlannedGift + plannedGift
    }
    
    func openSelectedItem(_ selectedItem: Any) {
        switch selectedItem {
        case let dashboardEventItem where dashboardEventItem is DashboardEventItem:
            self.performSegue(withIdentifier: Segues.toShowEvent, sender: dashboardEventItem)
        case let dashboardToDoItem as DashboardToDoItem:
            if let planItToDo = dashboardToDoItem.todoData as? PlanItTodo {
                self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: (planItToDo, dashboardToDoItem.actualDate))
            }
        case let purchaseItem where purchaseItem is DashboardPurchaseItem:
            self.performSegue(withIdentifier: Segues.toPurchaseDetails, sender: purchaseItem)
        case let giftItem where giftItem is DashboardGiftItem:
            self.performSegue(withIdentifier: Segues.toGiftCouponDetails, sender: giftItem)
        case let shopItem where shopItem is DashboardShopListItem:
            self.performSegue(withIdentifier: Segues.shoppingListItemDetail, sender: shopItem)
        default:
            break
        }
    }
    
    func refreshSearchDataWith(_ type: DashBoardTitle) {
        switch type {
        case .event:
            self.readEventsOf(.all)
        case .toDo:
            self.readToDos(.all)
        case .purchase:
            self.readPurchases(.all)
        case .giftCard:
            self.readGiftCards(.all)
        case .shopping:
            self.readShopping(.all)
        }
    }
    
    func updateSearchByDate() {
        let startDate = self.selectedFilterDate.initialHour()
        let endDate = self.selectedFilterDateEnd.initialHour().adding(days: 1).adding(seconds: -1)
        self.updateDateBy(startDate: startDate, endDate: endDate)
        self.showDateRange(startDate: startDate, endDate: endDate)
    }
    
    func showDateRange(startDate: Date, endDate: Date) {
        self.labelDateRange.text = "From: \(startDate.stringFromDate(format: DateFormatters.MMMSDCYYYY)) To: \(endDate.stringFromDate(format: DateFormatters.MMMSDCYYYY))"
    }
    
    func updateSearchIndex() {
        self.currentSearchEventIndex = 0
        self.currentSearchToDoIndex = 0
        self.currentSearchGiftIndex = 0
        self.currentSearchPurchaseIndex = 0
        self.currentSearchShoppingIndex = 0
        self.filterDateUpdatedEvent = true
        self.filterDateUpdatedToDo = true
        self.filterDateUpdatedGift = true
        self.filterDateUpdatedPurchase = true
        self.filterDateUpdatedShopping = true
    }
    
    func getSelectedSectionValue() -> Int {
        var selectedSectionValue = 0
        switch self.activeSection {
        case .event:
            selectedSectionValue = 0
        case .toDo:
            selectedSectionValue = 1
        case .shopping:
            selectedSectionValue = 2
        case .giftCard:
            selectedSectionValue = 3
        case .purchase:
            selectedSectionValue = 4
        }
        return selectedSectionValue
    }
}
