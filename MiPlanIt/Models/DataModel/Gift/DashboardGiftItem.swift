//
//  DashboardGiftItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardGiftItem {
    
    var tags: [String] = []
    var title: String = Strings.empty
    var description: String = Strings.empty
    var issuedBy: String = Strings.empty
    var exipryDate: Date?
    var createdDate: Date = Date()
    var planItGiftCoupon: PlanItGiftCoupon?
    
    init(_ planItGiftCoupon: PlanItGiftCoupon, converter: DatabasePlanItGiftCoupon) {
        self.title = planItGiftCoupon.readCouponName()
        self.description = planItGiftCoupon.readDescription()
        self.tags = planItGiftCoupon.readAllTags().compactMap({ $0.readTag() })
        self.exipryDate = planItGiftCoupon.readExpiryDateTime()
        self.issuedBy = planItGiftCoupon.readIssuedBy()
        self.createdDate = planItGiftCoupon.readCreatedDate()
        self.planItGiftCoupon = try? converter.mainObjectContext.existingObject(with: planItGiftCoupon.objectID) as? PlanItGiftCoupon
    }
    
    func readAllTags() -> [String] {
        return self.tags.compactMap({ $0.lowercased() })
    }
    
    func containsName(_ string: String) -> Bool {
        return self.title.lowercased().contains(string)
    }
    
    func containsTags(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsDescription(_ string: String) -> Bool {
        return self.description.lowercased().contains(string)
    }
}
