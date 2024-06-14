//
//  ClosedRange+Extension.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ClosedRange where Element: Hashable {
    func random(without excluded:[Element]) -> Element {
        let valid = Set(self).subtracting(Set(excluded))
        let random = Int(arc4random_uniform(UInt32(valid.count)))
        return Array(valid)[random]
    }
}
