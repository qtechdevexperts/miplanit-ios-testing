//
//  CalendarListBaseViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension CalendarListBaseViewController: CalanderNameCellDelegare {
    
    func calanderNameCell(_ calanderNameCell: CalanderNameCell, selectedCalendarItem calander: SocialCalendar) {
        calanderNameCell.startedDownloadProcess()
        self.updateProgress(atIndexPath: calanderNameCell.index)
        self.downloadCalnderEventsWithDelay(calander, atIndexPath: calanderNameCell.index)
    }
}

extension CalendarListBaseViewController: SocialManagerDelegate {
    
    func socialManagerFailedToLogin(_ manager: SocialManager) {
        self.showErrorScreenOnEmptyCalanderList()
    }
    
    func socialManagerFailedToRestore(_ manager: SocialManager) {
        self.showErrorScreenOnEmptyCalanderList()
    }
    //TODO: 
    func socialManager(_ manager: SocialManager, loginWithResult result: SocialUser) {
        switch manager.type {
        case .google:
            self.viewCalendarOwner.isHidden = false
            self.imgCalendarType.image = #imageLiteral(resourceName: "logoGoogleSmall")
            self.labelCalendarOwner.text = result.email
            self.labelCalendarOwner.isHidden = false
            self.labelEmail.isHidden = false
            self.labelCalendarCaption.isHidden = false
            
            self.createServiceToFetchGoogleUsersCalendar(result)
        case .outlook:
            self.viewCalendarOwner.isHidden = false
            self.imgCalendarType.image = #imageLiteral(resourceName: "icon_Outlook")
            self.labelCalendarOwner.text = result.email
            self.labelCalendarOwner.isHidden = false
            self.labelEmail.isHidden = false
            self.labelCalendarCaption.isHidden = false
            self.createServiceToFetchOutlookUsersCalendar(result)
        default:
            break
        }
    }
}
