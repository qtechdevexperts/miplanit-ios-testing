//
//  OutlookDeletedEvents.swift
//  MiPlanIt
//
//  Created by Arun on 07/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func refreshOutlookDeletedEvents() {
        guard !Session.shared.readUserId().isEmpty else { return }
        CalendarService().outlookDeletedEvents(callback: {_, _ in })
    }
}
