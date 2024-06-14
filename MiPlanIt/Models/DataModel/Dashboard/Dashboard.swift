//
//  Dashboard.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

class Dashboard {
    
    var planItDashBoard: PlanItDashboard?
    var name = Strings.empty
    var userDashboardImage = Strings.empty
    var userDashboardImageData: Data?
    var tags: [String] = []
    var excludedSections: [String] = []
    var appUserDashboardId: String = Strings.empty
    
    init() {
    }
    init(with planItDashboard: PlanItDashboard) {
        self.planItDashBoard = planItDashboard
        self.name = planItDashboard.readDashboardName()
        self.userDashboardImage = planItDashboard.readImageURL()
        self.userDashboardImageData = planItDashboard.dashboardImageData
        self.tags = planItDashboard.readTags().compactMap({ $0.tag })
        self.excludedSections = planItDashboard.readAllExcludedSections().compactMap({ $0.sectionName })
        self.appUserDashboardId = planItDashboard.appDashboardId ?? Strings.empty
    }
    func addTag(_ tag: String) {
        self.tags.append(tag)
    }
    
    func removeTagAtIndex(_ index: Int) {
        self.tags.remove(at: index)
    }
    
    func removeTag(_ tag: String) {
        self.tags.removeAll(where: { return $0 == tag })
    }
    
    func saveDashboardImage(_ image: String) {
        self.userDashboardImage = image
        self.userDashboardImageData = nil
        if let planItDashboard = self.planItDashBoard {
            planItDashboard.saveImageUrl(image)
        }
    }
    
    func savePlanItDashboard(_ planItDashboard: PlanItDashboard) {
        self.planItDashBoard = planItDashboard
    }
    
    func createRequestParameter() -> [String: Any] {
        var requestParameter: [String: Any] = [:]
        if let planItDashboard = self.planItDashBoard, planItDashboard.readValueOfDashboarId() != "0" {
            requestParameter["userDashboardId"] = planItDashboard.readValueOfDashboarId()
        }
        requestParameter["name"] = self.name
        requestParameter["tags"] = self.tags
        requestParameter["excludedSections"] = self.excludedSections
        requestParameter["appUserDashboardId"] = self.appUserDashboardId
        return requestParameter
    }
}
