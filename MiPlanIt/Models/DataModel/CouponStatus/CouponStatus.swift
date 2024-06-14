//
//  CouponStatus.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit


class CouponStatus: NSObject {
    
    let title: String
    let type: GiftCouponType
    var isSelected: Bool = false
    var icon: String
    init(title: String, type: GiftCouponType, isSelected: Bool = false, icon: String) {
        self.title = title
        self.type = type
        self.isSelected = isSelected
        self.icon = icon
    }
}
