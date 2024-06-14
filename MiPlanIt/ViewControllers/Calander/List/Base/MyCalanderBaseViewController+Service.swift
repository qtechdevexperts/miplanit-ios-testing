//
//  MyCalanderBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MyCalanderBaseViewController {
    
    func createServiceToFetchUsersData() {
        guard let user = self.requestUserCalendarDataIfNeeded() else { return }
        CalendarService().fetchUsersCalendarServerData(user, callback: { result, serviceDetection, error in
            self.refreshCalendarScreenWithUpdates(serviceDetection)
            self.calendarView.reloadData()
            
        })
    }
}
