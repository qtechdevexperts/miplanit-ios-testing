//
//  ViewDetailsCalendarData.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsCalendarData: UIView {

    @IBOutlet weak var labelCalendarName: UILabel!
    @IBOutlet weak var labelCalendarImage: UIImageView!
    
    func setValue(calendar: PlanItCalendar?, event: PlanItEvent?) {
        if let planItCalendar = calendar {
            self.labelCalendarName.text = event?.readEventCalendarName()
            self.readCalendarImage(planItCalendar)
        }
    }
    
    func setValue(calendar: OtherUserEvent, event: OtherUserEvent?) {
        self.labelCalendarName.text = event?.readEventCalendarName()
        self.readCalendarImage(calendar)
    }
        
    func readCalendarImage(_ calender: OtherUserEventCalendar?) {
        var createdUserDefaultImage: UIImage = #imageLiteral(resourceName: "calendar-image1")
        if let calendarName = calender?.calendarName {
            createdUserDefaultImage = calendarName.shortStringImage() ?? #imageLiteral(resourceName: "calendar-image1")
        }
        switch calender?.calendarType {
        case 1?:
            if let image = calender?.calendarImage, !image.isEmpty {
                self.labelCalendarImage.pinImageFromURL(URL(string: image), placeholderImage: createdUserDefaultImage)
            }
            else {
                self.labelCalendarImage.image = #imageLiteral(resourceName: "googleIcon")
            }
        case 2?:
            if let image = calender?.calendarImage, !image.isEmpty {
                self.labelCalendarImage.pinImageFromURL(URL(string: image), placeholderImage: createdUserDefaultImage)
            }
            else {
                self.labelCalendarImage.image = #imageLiteral(resourceName: "outlookIcon")
            }
        case 3?:
            if let image = calender?.calendarImage, !image.isEmpty {
                self.labelCalendarImage.pinImageFromURL(URL(string: image), placeholderImage: createdUserDefaultImage)
            }
            else {
                self.labelCalendarImage.image = #imageLiteral(resourceName: "appleIcon12")
            }
        default:
            if let image = calender?.calendarImage, !image.isEmpty {
                self.labelCalendarImage.pinImageFromURL(URL(string: image), placeholderImage: createdUserDefaultImage)
            }
            else {
                self.labelCalendarImage.image = #imageLiteral(resourceName: "calendar-image1")
            }
        }
    }
    
    func readCalendarImage(_ calender: PlanItCalendar?) {
        if let image = calender?.readCalendarImage(isFromEventDetailView: true) {
            if let urlImage = image.0 {
                self.labelCalendarImage.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.labelCalendarImage.image = image.1
            }
        }
    }
    
    func readCalendarImage(_ otherUserEvent: OtherUserEvent?) {
        var createdUserDefaultImage: UIImage = #imageLiteral(resourceName: "calendar-image1")
        if let createdBy = otherUserEvent?.createdBy {
            createdUserDefaultImage = createdBy.fullName.shortStringImage() ?? #imageLiteral(resourceName: "calendar-image1")
        }
        if let eventCalendar = otherUserEvent?.calendars.first {
            switch eventCalendar.calendarType {
            case 1:
                if !eventCalendar.calendarImage.isEmpty {
                    self.labelCalendarImage.pinImageFromURL(URL(string: eventCalendar.calendarImage), placeholderImage: createdUserDefaultImage)
                }
                else {
                    self.labelCalendarImage.image = #imageLiteral(resourceName: "googleIcon")
                }
            case 2:
                if !eventCalendar.calendarImage.isEmpty {
                    self.labelCalendarImage.pinImageFromURL(URL(string: eventCalendar.calendarImage), placeholderImage: createdUserDefaultImage)
                }
                else {
                    self.labelCalendarImage.image = #imageLiteral(resourceName: "outlookIcon")
                }
            case 3:
                if !eventCalendar.calendarImage.isEmpty {
                    self.labelCalendarImage.pinImageFromURL(URL(string: eventCalendar.calendarImage), placeholderImage: createdUserDefaultImage)
                }
                else {
                    self.labelCalendarImage.image = #imageLiteral(resourceName: "appleIcon")
                }
            default:
                if !eventCalendar.calendarImage.isEmpty {
                    self.labelCalendarImage.pinImageFromURL(URL(string: eventCalendar.calendarImage), placeholderImage: createdUserDefaultImage)
                }
                else if let createdBy = otherUserEvent?.createdBy {
                    self.labelCalendarImage.pinImageFromURL(URL(string: createdBy.profileImage), placeholderImage: createdUserDefaultImage)
                }
            }
        }
        else if let createdBy = otherUserEvent?.createdBy {
            self.labelCalendarImage.pinImageFromURL(URL(string: createdBy.profileImage), placeholderImage: createdUserDefaultImage)
        }
    }
}
