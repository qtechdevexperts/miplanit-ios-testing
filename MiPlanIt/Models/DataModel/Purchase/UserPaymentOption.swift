//
//  PurchasePaymentOption.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserPaymentOption {
    
    var isSelected: Bool
    var paymentCard: PlanItUserPayment
    
    init(with card: PlanItUserPayment, selected: Bool) {
        self.isSelected = selected
        self.paymentCard = card
    }
}
