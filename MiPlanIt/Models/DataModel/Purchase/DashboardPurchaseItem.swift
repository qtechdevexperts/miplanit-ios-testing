//
//  DashboardPurchaseItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardPurchaseItem {
    
    var tags: [String] = []
    var title: String = Strings.empty
    var description: String = Strings.empty
    var planItPurchase: PlanItPurchase?
    var bilDateTime: Date = Date()
    var createdDate: Date = Date()
    
    init(_ planItPurchase: PlanItPurchase, converter: DatabasePlanItPurchase) {
        self.title = planItPurchase.readProductName()
        self.description = planItPurchase.readDescription()
        self.tags = planItPurchase.readAllTags().map({ $0.readTag() })
        self.bilDateTime = planItPurchase.billDate ?? Date()
        self.createdDate = planItPurchase.readCreatedDate()
        self.planItPurchase = try? converter.mainObjectContext.existingObject(with: planItPurchase.objectID) as? PlanItPurchase
    }
    
    func readAllTags() -> [String] {
        return self.tags.compactMap({ $0.lowercased() })
    }
    
    func containsName(_ string: String) -> Bool {
        return self.title.lowercased().contains(string)
    }
    
    func containsTag(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsTags(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsDescription(_ string: String) -> Bool {
        return self.description.lowercased().contains(string)
    }
}
