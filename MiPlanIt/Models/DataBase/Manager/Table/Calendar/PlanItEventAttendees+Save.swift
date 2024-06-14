//
//  PlanItEventAttendees+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension PlanItEventAttendees {

    func readEmail() -> String { return self.email ?? Strings.empty }
    func readStatus() -> String { return self.status ?? Strings.empty }
    func readName() -> String { return self.name ?? Strings.empty }

    var readSharedStatus: Double {
        get {
            guard let sharedStatus = self.status else {
                return 0
            }
            if sharedStatus == "accepted" {
                return 1
            }
            else if sharedStatus == "declined" {
                return 2
            }
            else {
                return 0
            }
        }
    }
}
