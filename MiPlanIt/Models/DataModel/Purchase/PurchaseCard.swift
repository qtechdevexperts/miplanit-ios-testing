//
//  PurchaseCard.swift
//  MiPlanIt
//
//  Created by Arun on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class PurchaseCard: Comparable {
    
    let cardName: String
    let cardNumber: String
    
    init(with name: String, number: String) {
        self.cardName = name
        self.cardNumber = number
    }
    
    static func ==(lhs: PurchaseCard, rhs: PurchaseCard) -> Bool {
        return lhs.cardNumber == rhs.cardNumber
    }
    
    static func < (lhs: PurchaseCard, rhs: PurchaseCard) -> Bool {
        return lhs.cardNumber == rhs.cardNumber
    }
}
