//
//  PlanItDataStorage+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension PlanItDataStorage {

    func readUsedSpace() -> String {
        return self.usedSpace.cleanValues(decimals: 3) + " MB"
    }
    func readTotalSpace() -> String { return "\(self.totalSpace/1024)" + " GB" }
}
