//
//  AddCalendarViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 13/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddCalendarViewController {
    
    func saveCalendarToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            self.createServiceToAddNewCalendar()
        }
        else {
            let data = self.imageViewCalendarImage.image?.jpegData(compressionQuality: 0.5)
            let planItCalendar = DatabasePlanItCalendar().insertNewOfflinePlanItCalendar(self.calendar, file: data)
            Session.shared.loadFastestCalendars()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.addCalendarViewController(self, createdNewCalendar: planItCalendar)
        }
    }
}
