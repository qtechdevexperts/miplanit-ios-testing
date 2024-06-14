//
//  PlanItUserPayment+Save.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItUserPayment {
    
    func readCardName() -> String {
        return self.cardName ?? Strings.empty
    }
    
    func readCardNumber() -> String {
        return self.cardNumber ?? Strings.empty
    }
}
