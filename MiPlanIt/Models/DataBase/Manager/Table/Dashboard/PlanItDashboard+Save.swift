//
//  PlanItDashboard+Save.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension PlanItDashboard {
    
    func readTags() -> [PlanItTags] {
        if let tags = self.tags, let shopTags = Array(tags) as? [PlanItTags] {
            return shopTags
        }
        return []
    }
    
    func readAllExcludedSections() -> [PlanItExcludedSections] {
        if let section = self.excludedSections, let shopSection = Array(section) as? [PlanItExcludedSections] {
            return shopSection
        }
        return []
    }
    
    func readValueOfDashboarId() -> String {
        return self.userDashboardId.cleanValue()
    }
    
    func readOwnerUserId() -> String {
        self.createdBy?.readValueOfUserId() ?? Strings.empty
    }
    
    func readDashboardName() -> String {
        return self.name ?? Strings.empty
    }
    func readImageURL() -> String {
        return self.userDashboardImage ?? Strings.empty
    }
    
    func readImage() -> Any {
        return self.dashboardImageData ?? self.readImageURL()
    }
    
    func saveImageUrl(_ url: String) {
        self.userDashboardImage = url
        if let dashboardURL = URL(string:url) {
            let orginal = PINRemoteImageManager.shared().cacheKey(for: dashboardURL, processorKey: nil)
            PINRemoteImageManager.shared().cache.removeObject(forKey: orginal)
            let rounded = PINRemoteImageManager.shared().cacheKey(for: dashboardURL, processorKey: "rounded")
            PINRemoteImageManager.shared().cache.removeObject(forKey: rounded)
        }
        self.managedObjectContext?.saveContext()
    }
    
    func deleteItSelf() {
        let context = self.managedObjectContext
        context?.delete(self)
        try? context?.save()
    }
    
    func deleteAllTags() {
        let allTags = self.readTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteExcludedSection() {
        let allTags = self.readAllExcludedSections()
        self.removeFromTags(self.excludedSections ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
}
