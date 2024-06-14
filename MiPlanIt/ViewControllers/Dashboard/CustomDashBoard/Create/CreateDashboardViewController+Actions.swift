//
//  CreateDashboardViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 12/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension CreateDashboardViewController {
    // MARK: - Initial setup
    func initialiseDashboardDetails() {
        self.buttonUploadProfilePic.isHidden = true
        self.buttonEditPic.isHidden = self.dashboardModel.planItDashBoard == nil || (self.dashboardModel.userDashboardImage == Strings.empty && self.dashboardModel.userDashboardImageData == nil)
        if self.dashboardModel.planItDashBoard != nil {
            self.textFieldName.text = self.dashboardModel.name
            var excludedSection: [DashboardSectionType] = []
            self.allSections.forEach { (section) in
                if self.dashboardModel.excludedSections.contains(section.rawValue) {
                    excludedSection.append(section)
                    switch section {
                    case .event:
                        self.selectButton(self.buttonEvent)
                    case .gift:
                        self.selectButton(self.buttonGift)
                    case .purchase:
                        self.selectButton(self.buttonPurchase)
                    case .shopping:
                        self.selectButton(self.buttonShopping)
                    case .todo:
                        self.selectButton(self.buttonTodo)
                    }
                }
            }
            self.excludedSection = excludedSection
            if let imageData = self.dashboardModel.userDashboardImageData {
                self.imageViewDashboardPic.image = UIImage(data: imageData)
            }
            else {
                self.imageViewDashboardPic.pinImageFromURL(URL(string: self.dashboardModel.userDashboardImage), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
            }
        }
        self.setAllAddedTags()
        self.setShowAddedTags(excludeSections: self.dashboardModel.excludedSections)
    }
    
    func setShowAddedTags(excludeSections: [String], onSearchText: String = Strings.empty, selectionFlag: Bool? = nil) {
        let excludedSections = Set(excludeSections)
        var showTags = self.allAddedTags.filter({
            let sectionTypes = Set($0.sectionType.map({ $0.rawValue.lowercased() }))
            return !sectionTypes.isSubset(of: excludedSections)
        })
        if !onSearchText.isEmpty {
            showTags = showTags.filter({ $0.stringtag.lowercased().contains(onSearchText.lowercased()) })
        }
        else {
            self.allAddedTags.filter({ !showTags.contains($0) }).forEach { (tag) in
                tag.isSelected = false
            }
        }
        if let selection = selectionFlag {
            showTags.forEach({ $0.isSelected = selection })
        }
        self.showAddedTags = showTags
        self.buttonSelectAll.isSelected = self.showAddedTags.filter({ !$0.isSelected }).isEmpty
    }
    
    
    func setAllAddedTags() {
        let planItTags = DatabasePlanItTags().readAllTags().filter({ $0.dashboard == nil })
        planItTags.forEach { (planItTag) in
            if planItTag.event != nil, let dashBoardTag = self.appendEventSectionType(tag: planItTag) {
                self.allAddedTags.append(dashBoardTag)
            }
            else if planItTag.giftCoupon != nil, let dashBoardTag = self.appendGiftSectionType(tag: planItTag) {
                self.allAddedTags.append(dashBoardTag)
            }
            else if planItTag.purchase != nil, let dashBoardTag = self.appendPurchaseSectionType(tag: planItTag) {
                self.allAddedTags.append(dashBoardTag)
            }
            else if planItTag.shopListItems != nil, let dashBoardTag = self.appendShoppingSectionType(tag: planItTag) {
                self.allAddedTags.append(dashBoardTag)
            }
            else if planItTag.todo != nil, let dashBoardTag = self.appendToDoSectionType(tag: planItTag) {
                self.allAddedTags.append(dashBoardTag)
            }
        }
        self.userAvailablePlanItCalendars.forEach { (planItCalendar) in
            if let dashboardTag = self.appendEventSectionType(calendar: planItCalendar) {
                self.allAddedTags.append(dashboardTag)
            }
        }
        self.allAddedTags.forEach { (dashboarTag) in
            dashboarTag.updateSelection(dashboard: self.dashboardModel)
        }
    }
    
    func appendEventSectionType(tagName: String) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tagName.lowercased() }).first {
            if !addedtag.sectionType.contains(.event) {
                addedtag.sectionType.append(.event)
            }
            return nil
        }
        return DashboardTag(tag: tagName)
    }
    
    func appendEventSectionType(calendar: PlanItCalendar) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == calendar.readValueOfOrginalCalendarName().lowercased() }).first {
            if !addedtag.sectionType.contains(.event) {
                addedtag.sectionType.append(.event)
            }
            return nil
        }
        return DashboardTag(calendar: calendar)
    }
    
    func appendEventSectionType(tag: PlanItTags) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tag.readTag().lowercased() }).first {
            if !addedtag.sectionType.contains(.event) {
                addedtag.sectionType.append(.event)
            }
            return nil
        }
        return DashboardTag(planItTag: tag)
    }
    
    func appendGiftSectionType(tag: PlanItTags) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tag.readTag().lowercased() }).first {
            if !addedtag.sectionType.contains(.gift) {
                addedtag.sectionType.append(.gift)
            }
            return nil
        }
        return DashboardTag(planItTag: tag)
    }
    
    func appendPurchaseSectionType(tag: PlanItTags) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tag.readTag().lowercased() }).first {
            if !addedtag.sectionType.contains(.purchase) {
                addedtag.sectionType.append(.purchase)
            }
            return nil
        }
        return DashboardTag(planItTag: tag)
    }
    
    func appendToDoSectionType(tag: PlanItTags) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tag.readTag().lowercased() }).first {
            if !addedtag.sectionType.contains(.todo) {
                addedtag.sectionType.append(.todo)
            }
            return nil
        }
        return DashboardTag(planItTag: tag)
    }
    
    func appendShoppingSectionType(tag: PlanItTags) -> DashboardTag? {
        if let addedtag = self.allAddedTags.filter({ $0.stringtag.lowercased() == tag.readTag().lowercased() }).first {
            if !addedtag.sectionType.contains(.shopping) {
                addedtag.sectionType.append(.shopping)
            }
            return nil
        }
        return DashboardTag(planItTag: tag)
    }
    
    func validateSectionSelection(_ sender: UIButton) -> Bool {
        return self.excludedSection.count < self.allSections.count - 1 || sender.isSelected
    }
    
    func selectButton(_ button: UIButton) {
        button.isSelected = true
        button.backgroundColor =  UIColor.init(red: 1.0, green: 163/255.0, blue: 68/255.0, alpha: 1.0)
        button.bordorWidth = 0
    }
    
    func unSelectButton(_ button: UIButton) {
        button.isSelected = false
        button.backgroundColor =  .clear//.white
        button.bordorWidth = 0.5
    }
    
    func validateData() -> Bool {
        self.view.endEditing(true)
        var dashboardName = false
        do {
            dashboardName = try self.textFieldName.validateTextWithType(.username)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldName.showError(validationError.message, animated: true)
            return false
        }
        if self.customDashboardProfiles.filter({ return $0.planItDashboardName == self.textFieldName.text && $0.planItDashboard.readValueOfDashboarId() != self.dashboardModel.planItDashBoard?.readValueOfDashboarId()}).isEmpty {
            return true && dashboardName
        }
        else {
            self.textFieldName.showError(Strings.namealreadyexists, animated: true)
            return false && dashboardName
        }
    }
    
    func updateDashboardModel() {
        self.dashboardModel.excludedSections = self.excludedSection.map({ $0.rawValue })
        self.dashboardModel.tags = self.allAddedTags.filter({ $0.isSelected }).map({ $0.stringtag })
        self.dashboardModel.name = self.textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
    }
    
    func updateSections() {
        var excludeSection: [DashboardSectionType] = []
        if self.buttonEvent.isSelected {
            excludeSection.append(.event)
        }
        if self.buttonGift.isSelected {
            excludeSection.append(.gift)
        }
        if self.buttonTodo.isSelected {
            excludeSection.append(.todo)
        }
        if self.buttonPurchase.isSelected {
            excludeSection.append(.purchase)
        }
        if self.buttonShopping.isSelected {
            excludeSection.append(.shopping)
        }
        self.excludedSection = excludeSection
        self.setShowAddedTags(excludeSections: excludeSection.map({ $0.rawValue }))
        self.textFieldSearch.text = Strings.empty
        self.viewSearch.isHidden = true
    }
    
    func updateShowTagOnSearch() {
        let searchText = self.textFieldSearch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.setShowAddedTags(excludeSections: self.excludedSection.map({ $0.rawValue }), onSearchText: searchText)
    }
    
    func updateTagSelection(isSelected: Bool) {
        let searchText = self.textFieldSearch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        self.setShowAddedTags(excludeSections:  self.excludedSection.map({ $0.rawValue }), onSearchText: searchText, selectionFlag: isSelected)
    }
    
    func isHelpShown() -> Bool {
        return Storage().readBool(UserDefault.createDashboardHelp) ?? false
    }
}
