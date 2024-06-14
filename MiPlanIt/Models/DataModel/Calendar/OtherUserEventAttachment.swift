//
//  OtherUserEventAttachment.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class OtherUserEventAttachment {
    
    var fileUrl: String
    var title: String
    var iconLink: String
    
    init(with attachment: [String: Any]) {
        self.fileUrl = attachment["ileUrl "] as? String ?? Strings.empty
        self.title = attachment["title"] as? String ?? Strings.empty
        self.iconLink = attachment["iconLink"] as? String ?? Strings.empty
    }
    
    init(with planItEventAttendees: PlanItEventAttachment) {
        self.fileUrl = planItEventAttendees.readFileUrl()
        self.title = planItEventAttendees.readTitle()
        self.iconLink = planItEventAttendees.readIconLink()
    }
}
