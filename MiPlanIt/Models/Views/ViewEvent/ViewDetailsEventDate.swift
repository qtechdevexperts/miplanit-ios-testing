//
//  ViewDetailsEventDate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsEventDate: UIView {

    @IBOutlet weak var imageViewOrganizer: UIImageView?
    @IBOutlet weak var labelEventName: UILabel!
    @IBOutlet weak var labelEventDate: UILabel!
    @IBOutlet weak var labelEventTime: UILabel!
    @IBOutlet weak var labelRepeatInfo: UILabel!
    @IBOutlet weak var labelTravellingInfo: UILabel!
    @IBOutlet weak var viewEventColor: UIView!
    @IBOutlet weak var viewOrganizer: UIView?
    @IBOutlet weak var labelOrganizerName: UILabel?
    @IBOutlet weak var labelOrganizerEmail: UILabel?
    
    
    func setDate(event: PlanItEvent, dateEvent: DateSpecificEvent) {
        self.labelEventName.text = event.readValueOfEventName()
        if event.isAllDay {
            if event.readEndDateTimeFromDate(dateEvent.startDate).dayDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) == 1 {
                self.labelEventDate.text = Strings.empty
            }
            else {
                self.labelEventDate.text = event.readStartDateTimeFromDate(dateEvent.startDate).stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
            }
            self.labelEventTime.text = event.readEndDateTimeFromDate(dateEvent.startDate).adding(minutes: -1).stringFromDate(format: DateFormatters.EEEDDMMMYYYY) + " (" + event.readEndDateTimeFromDate(dateEvent.startDate).timeDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) + ")"
        }
        else {
            self.labelEventDate.text = event.readStartDateTimeFromDate(dateEvent.startDate).stringFromDate(format: DateFormatters.EEEMMMDDYYYYHSSA)
            self.labelEventTime.text = event.readEndDateTimeFromDate(dateEvent.startDate).stringFromDate(format: DateFormatters.EEEMMMDDYYYYHSSA) + " (" + event.readEndDateTimeFromDate(dateEvent.startDate).timeDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) + ")"
        }
        self.labelTravellingInfo.text = event.isUserTravelling() ? Strings.travelling : Strings.empty
        self.viewEventColor.backgroundColor = event.readCalendarColorCode()
        self.labelRepeatInfo.text = event.readRecurrenceStatement()
        if event.isSocialCalendarEvent() {
            let name = event.readSocialCalendarEventCreatorName()
            self.labelOrganizerName?.text = name
            self.imageViewOrganizer?.image = name?.shortStringImage()
            let socialEmail = event.readSocialCalendarEventCreatorEmail()
            self.labelOrganizerEmail?.isHidden = socialEmail == name || socialEmail.isEmpty
            self.labelOrganizerEmail?.text = socialEmail
            self.viewOrganizer?.isHidden = (name ?? Strings.empty).isEmpty && socialEmail.isEmpty
            if !socialEmail.isEmpty, let invitee = event.readAllInvitees().filter({ $0.readValueOfEmail() == socialEmail }).first {
                self.imageViewOrganizer?.pinImageFromURL(URL(string: invitee.readValueOfProfileImage()), placeholderImage: invitee.readValueOfFullName().shortStringImage())
            }
        }
        else {
            let name = (event.createdBy?.readValueOfFullName().isEmpty ?? true) ? ((event.createdBy?.readValueOfEmail().isEmpty ?? true) ? event.createdBy?.readValueOfPhone() : event.createdBy?.readValueOfEmail() ) : event.createdBy?.readValueOfFullName()
            self.labelOrganizerName?.text = name
            self.labelOrganizerEmail?.isHidden = (event.createdBy?.readValueOfEmail() ?? Strings.empty) == name || (event.createdBy?.readValueOfEmail() ?? Strings.empty).isEmpty
            self.labelOrganizerEmail?.text = (event.createdBy?.readValueOfEmail() ?? Strings.empty)
            self.viewOrganizer?.isHidden = (name ?? Strings.empty).isEmpty && (self.labelOrganizerEmail?.text ?? Strings.empty).isEmpty
            self.imageViewOrganizer?.pinImageFromURL(URL(string: event.createdBy?.profileImage ?? Strings.empty), placeholderImage: event.createdBy?.readValueOfFullName().shortStringImage())
        }
    }
    
    func setDate(event: OtherUserEvent, dateEvent: DateSpecificEvent) {
        self.labelEventName.text = event.eventName
        
        if event.isAllDay {
            if event.readEndDateTimeFromDate(dateEvent.startDate).dayDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) == 1 {
                self.labelEventDate.text = Strings.empty
            }
            else {
                self.labelEventDate.text = dateEvent.startDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
            }
            self.labelEventTime.text = event.readEndDateTimeFromDate(dateEvent.startDate).adding(minutes: -1).stringFromDate(format: DateFormatters.EEEDDMMMYYYY) + " (" + event.readEndDateTimeFromDate(dateEvent.startDate).timeDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) + ")"
        }
        else {
            self.labelEventDate.text = event.readStartDateTimeFromDate(dateEvent.startDate).stringFromDate(format: DateFormatters.EEEMMMDDYYYYHSSA)
            self.labelEventTime.text = event.readEndDateTimeFromDate(dateEvent.startDate).stringFromDate(format: DateFormatters.EEEMMMDDYYYYHSSA) + " ( " + event.readEndDateTimeFromDate(dateEvent.startDate).timeDiffrence(from: event.readStartDateTimeFromDate(dateEvent.startDate)) + " ) "
        }
        self.labelTravellingInfo.text = event.isAvailable == 1 ? Strings.travelling : Strings.empty
        self.viewEventColor.backgroundColor = event.readCalendarColorCode()
        self.labelRepeatInfo.text = event.readRecurrenceStatement()
        if event.isSocialCalendarEvent() {
            let name = event.readSocialCalendarEventCreatorName()
            self.labelOrganizerName?.text = name
            self.imageViewOrganizer?.image = name.shortStringImage()
            let socialEmail = event.readSocialCalendarEventCreatorEmail()
            self.labelOrganizerEmail?.isHidden = socialEmail == name || (socialEmail).isEmpty
            self.labelOrganizerEmail?.text = socialEmail
            self.viewOrganizer?.isHidden = (name).isEmpty && (socialEmail).isEmpty
            if let invitee = event.invitees.filter({ $0.email == event.readSocialCalendarEventCreatorEmail() }).first {
                self.imageViewOrganizer?.pinImageFromURL(URL(string: invitee.profileImage), placeholderImage: invitee.fullName.shortStringImage())
            }
        }
        else {
            let name = (event.createdBy?.fullName.isEmpty ?? true ) ? ((event.createdBy?.email.isEmpty ?? true) ? event.createdBy?.phone : event.createdBy?.email ) : event.createdBy?.fullName
            self.labelOrganizerName?.text = name
            self.labelOrganizerEmail?.isHidden = (event.createdBy?.email ?? Strings.empty) == name || (event.createdBy?.email ?? Strings.empty).isEmpty
            self.labelOrganizerEmail?.text = (event.createdBy?.email ?? Strings.empty)
            self.viewOrganizer?.isHidden = (name ?? Strings.empty).isEmpty && (self.labelOrganizerEmail?.text ?? Strings.empty).isEmpty
            self.imageViewOrganizer?.pinImageFromURL(URL(string: event.createdBy?.profileImage ?? Strings.empty), placeholderImage: event.createdBy?.fullName.shortStringImage())
        }
    }
}
