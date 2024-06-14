//
//  UserCalendarListViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 14/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension UserCalendarListViewController {
    
    func saveCalendarDeleteToServerUsingNetwotk(_ calendar: PlanItCalendar, index: IndexPath) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToDeleteCalendar(calendar, index: index)
        }
        else {
            Session.shared.removeCalendarNotification(calendar.readValueOfCalendarId())
            DatabasePlanItEvent().removedPlantItEventsFromCalendar(calendar)
            calendar.saveCalendarDeleteStatus(true)
            self.refreshCalendarAfterDelete(calendar, index: index)
        }
    }
    
    func saveSharedCalendarDeleteToServerUsingNetwotk(_ calendar: PlanItCalendar, index: IndexPath) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToDeleteSharedCalendar(calendar, index: index)
        }
        else {
            Session.shared.removeCalendarNotification(calendar.readValueOfCalendarId())
            DatabasePlanItEvent().removedPlantItEventsFromCalendar(calendar)
            calendar.saveCalendarDeleteStatus(true)
            self.refreshCalendarAfterDelete(calendar, index: index)
        }
    }
}
