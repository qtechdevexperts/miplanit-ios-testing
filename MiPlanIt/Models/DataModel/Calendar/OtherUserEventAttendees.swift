//
//  OtherUserEventAttendees.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class OtherUserEventAttendees {
    
    var email: String
    var name: String
    var status: String
    
    init(with attendees: [String: Any]) {
        self.email = attendees["email"] as? String ?? Strings.empty
        self.name = attendees["name"] as? String ?? Strings.empty
        self.status = attendees["status"] as? String ?? Strings.empty
    }
    
    init(with planItEventAttendees: PlanItEventAttendees) {
        self.email = planItEventAttendees.readEmail()
        self.name = planItEventAttendees.readName()
        self.status = planItEventAttendees.readStatus()
    }
    
    var readSharedStatus: Double {
        get {
            if self.status == "accepted" {
                return 1
            }
            else if self.status == "declined" {
                return 2
            }
            else {
                return 0
            }
        }
    }
}
