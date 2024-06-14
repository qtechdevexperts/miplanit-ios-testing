//
//  DoubleExtension.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Double {
    
    func cleanValue() -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
    
    func cleanValues(decimals: Double) -> String {
        return("\(Double((self * pow(10.0, decimals)).rounded() / pow(10.0, decimals)))")
    }
    
    
    func readCurrencyValue() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
