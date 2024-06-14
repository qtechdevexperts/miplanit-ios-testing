//
//  DashboardTag.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardTag: Hashable, Equatable {
    
    var planItTag: PlanItTags?
    var stringtag: String = Strings.empty
    var isSelected: Bool = false
    var sectionType: [DashboardSectionType] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stringtag)
    }
    
    static func ==(left:DashboardTag, right:DashboardTag) -> Bool {
        return left.stringtag.lowercased() == right.stringtag.lowercased()
    }
    
    init(planItTag: PlanItTags) {
        self.planItTag = planItTag
        self.stringtag =  self.planItTag?.tag ?? Strings.empty
        if planItTag.event != nil {
            self.sectionType.append(.event)
        }
        else if planItTag.giftCoupon != nil {
            self.sectionType.append(.gift)
        }
        else if planItTag.purchase != nil {
            self.sectionType.append(.purchase)
        }
        else if planItTag.shopListItems != nil {
            self.sectionType.append(.shopping)
        }
        else if planItTag.todo != nil {
            self.sectionType.append(.todo)
        }
    }
    
    init(calendar: PlanItCalendar) {
        self.stringtag =  calendar.readValueOfOrginalCalendarName()
        self.sectionType.append(.event)
    }
    
    init(tag: String) {
        self.stringtag =  tag
        self.sectionType.append(.event)
    }
    
    func updateSelection(dashboard: Dashboard) {
        let containsTag: Bool = dashboard.tags.map({$0.lowercased()}).contains(self.stringtag.lowercased())
        
        let sectionTypes = self.sectionType.map({ $0.rawValue.lowercased() })
        let excludedSection = dashboard.excludedSections.map({ $0.lowercased() })
        
        if sectionTypes.containsSameElements(as: excludedSection) {
            self.isSelected = false
        }
        else {
            self.isSelected = containsTag
        }
    }
    
    func setSelection(_ flag: Bool) {
        self.isSelected = flag
    }
}
