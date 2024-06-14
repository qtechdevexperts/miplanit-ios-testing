//
//  ViewEventViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MapKit

extension ViewEventViewController {
    
    func initialiseUIComponents() {
        self.viewTopColorHeader.isHidden = self.navigationController == nil
        self.viewTopNonColorHeader.isHidden = self.navigationController != nil
        self.viewTopBarGradient.isHidden = self.navigationController == nil
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            self.showPlanItEventDetails(planItEvent)
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            self.showOtherUserEventDetails(otherUserEvent)
        }
        self.loadInterstilialAds()
    }
    
    func loadInterstilialAds() {
        self.showInterstitalViewController()
    }
    
    func openMapForPlace(latitude: Double, longitude: Double, name: String) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }

    
    func showPlanItEventDetails(_ event: PlanItEvent) {
        let isGoogleEvent: Bool = self.isGoogleSocialEvent(event)
        self.viewDetailsDescription.setDescription(event.readValueOfEventDescription(), htmlString: event.readHtmlLink(), isGoogleEvent: isGoogleEvent, conferenceData: event.readConferenceData())
        let tag = event.readAllTags()
        self.updateTagUI(tags: tag.compactMap({ $0.tag }) )
        let calendar = event.readMainCalendar()?.calendar
        self.viewDetailsEventDate.setDate(event: event, dateEvent: self.dateEvent)
        self.viewDetailsCalendarData.setValue(calendar: calendar, event: event)
        self.viewDetailsInvitees.setInvitees(event.readViewEventOtherUsersIncludingLoginUser())
        self.viewDetailsLocation.setLocationValue(event.readLocation())
        event.isSocialEvent ? self.updateSocialEventRemindMeTitle(reminder: event.readReminders()) : self.updateRemindMeTitle(reminder: event.readReminders())
        self.buttonDelete.isHidden = calendar?.canEdit == false || self.hideDeleteButton(planItEvent: event)
        self.buttonEdit.isHidden = !(calendar?.canEdit == true && (DatabasePlanItSocialUser().checkUserExistsInMiPlaniT(event.readSocialCalendarEventCreatorEmail()) || (event.createdBy?.readValueOfUserId() == Session.shared.readUserId() && !event.isSocialEvent))) || self.isAppleSocialEvent(event)
    }
    
    func isAppleSocialEvent(_ planItEvent: PlanItEvent) -> Bool {
        return planItEvent.isSocialCalendarEvent() && planItEvent.readEventCalendar()?.readValueOfCalendarType() == "3"
    }
    
    func isGoogleSocialEvent(_ planItEvent: PlanItEvent) -> Bool {
        return planItEvent.isSocialCalendarEvent() && planItEvent.readEventCalendar()?.readValueOfCalendarType() == "1"
    }
    
    func isGoogleSocialEvent(_ otherUserEvent: OtherUserEvent) -> Bool {
        return otherUserEvent.isSocialCalendarEvent() && otherUserEvent.readMainCalendar()?.calendarType == 1
    }
    
    func hideDeleteButton(planItEvent: PlanItEvent) -> Bool {
        if self.isAppleSocialEvent(planItEvent) {
            return true
        }
        return !(DatabasePlanItSocialUser().checkUserExistsInMiPlaniT(planItEvent.readSocialCalendarEventCreatorEmail()) || (planItEvent.createdBy?.readValueOfUserId() == Session.shared.readUserId() && !planItEvent.isSocialEvent))
    }
    
    func updateRemindMeTitle(reminder: PlanItReminder?) {
        if let remider = reminder, let unit = remider.readIntervalUnit() {
            self.viewDetailsRemindMe.setValue("\(Int(remider.readInterval())) \(unit) before")
            return
        }
        self.viewDetailsRemindMe.setValue(Strings.empty)
    }
    
    func updateSocialEventRemindMeTitle(reminder: PlanItReminder?) {
        if let remider = reminder {
            self.viewDetailsRemindMe.setReminderValueAndUnit(remider)
            return
        }
        self.viewDetailsRemindMe.setValue(Strings.empty)
    }
    
    func showOtherUserEventDetails(_ event: OtherUserEvent) {
        let isGoogleEvent: Bool = self.isGoogleSocialEvent(event)
        self.viewDetailsDescription.setDescription(event.eventDescription, htmlString: event.htmlLink, isGoogleEvent: isGoogleEvent, conferenceData: event.readConferenceData())
        self.updateTagUI(tags: event.tags)
        self.viewDetailsEventDate.setDate(event: event, dateEvent: self.dateEvent)
        if let eventId = Double(event.eventId), let planItEvent = DatabasePlanItEvent().readPlanItEventsWith(eventId), let planItCalendar = planItEvent.readMainCalendar()?.calendar {
            self.buttonDelete.isHidden = planItCalendar.canEdit == false || self.hideDeleteButton(planItEvent: planItEvent)
            self.buttonEdit.isHidden = !(planItCalendar.canEdit && planItEvent.createdBy?.readValueOfUserId() == Session.shared.readUserId() && !planItEvent.isSocialCalendarEvent()) || self.isAppleSocialEvent(planItEvent)
            self.viewDetailsCalendarData.setValue(calendar: planItCalendar, event: planItEvent)
        }
        else {
            self.buttonEdit.isHidden = true
            self.buttonDelete.isHidden = true
            self.viewDetailsCalendarData.setValue(calendar: event, event: event)
        }
        self.viewDetailsInvitees.setInvitees(event.readOtherUsers())
        self.viewDetailsLocation.setLocationValue(event.location)
        self.viewDetailsVideoConference.setValue(event.conferenceUrl)
        self.viewDetailsVideoConference.isHidden = event.conferenceUrl.isEmpty
        event.isSocialEvent ? self.updateSocialEventRemindMeTitle(reminder: event.readReminder()) : self.updateRemindMeTitle(otheruserReminder: event.readReminder())
        self.viewDetailPhoneConference.setPhoneConferenceData(event.fullConferenceData)
        self.viewDetailSIPConference.setSIPConferenceData(event.fullConferenceData)
        if self.isGoogleSocialEvent(event) {
            self.viewDetailsVideoConference.setVideoConferenceData(event.fullConferenceData)
        }
        else {
            self.viewDetailsVideoConference.setValue(event.conferenceUrl)
            self.viewDetailsVideoConference.isHidden = event.conferenceUrl.isEmpty
        }
    }
    
    func updateTagUI(tags: [String]) {
        if self.navigationController == nil {
            self.buttonPresentTag.isHidden = tags.isEmpty
            self.labelPresentTagCount.isHidden = tags.isEmpty
            self.labelPresentTagCount.text = "\(tags.count)"
        }
        else {
           //self.buttonTag.isHidden = tags.isEmpty
            self.labelTagCount.isHidden = tags.isEmpty
            self.labelTagCount.text = "\(tags.count)"
        }
    }
    
    func updateRemindMeTitle(otheruserReminder: OtherUserReminders?) {
        if let remider = otheruserReminder {
            self.viewDetailsRemindMe.setValue("\(remider.interval) \(remider.readUnit()) before")
            return
        }
        self.viewDetailsRemindMe.setValue(Strings.empty)
    }
    
    func updateSocialEventRemindMeTitle(reminder: OtherUserReminders?) {
        if let remider = reminder {
            self.viewDetailsRemindMe.setReminderValueAndUnit(remider)
            return
        }
        self.viewDetailsRemindMe.setValue(Strings.empty)
    }
    
    func deleteEventsFromModifiedList(_ events: [PlanItEvent]) {
        guard let modifiedUserEvents = self.modifiedEvents as? [PlanItEvent] else { return }
        let deletedIds = events.map({ return $0.readValueOfEventId() })
        self.modifiedEvents = modifiedUserEvents.filter({ return !deletedIds.contains($0.readValueOfEventId()) })
    }
    
    func deleteEventsFromModifiedList(_ events: [OtherUserEvent]) {
        guard let modifiedUserEvents = self.modifiedEvents as? [OtherUserEvent] else { return }
        let deletedIds = events.map({ return $0.eventId })
        self.modifiedEvents = modifiedUserEvents.filter({ return !deletedIds.contains($0.eventId) })
    }
    
    func createEventModelForEditEvent(withType type: RecursiveEditOption) -> MiPlanItEvent {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return self.createEventModelFromPlantItEvent(planItEvent, type: type)
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return self.createEventModelFromOtherUserEvent(otherUserEvent, type: type)
        }
        return MiPlanItEvent()
    }
    
    func createEventModelFromPlantItEvent(_ event: PlanItEvent, type: RecursiveEditOption) -> MiPlanItEvent {
        let newEventModel = MiPlanItEvent()
        newEventModel.event = event
        newEventModel.eventId = event.readValueOfEventId()
        newEventModel.appEventId = event.readValueOfAppEventId()
        newEventModel.tags = event.readAllTags().compactMap({$0.tag})
        newEventModel.isAllday = event.isAllDay
        newEventModel.isTravelling = event.isUserTravelling()
        newEventModel.isRecurrance = event.isRecurrence
        newEventModel.isOtherUserEvent = self.isOtherUserType()
        newEventModel.endTime = event.readEndTime()
        newEventModel.location = event.readLocationString()
        newEventModel.eventName = event.readValueOfEventName()
        newEventModel.bodyContentType = event.readBodyContentType()
        newEventModel.eventDescription = event.readValueOfEventDescription()
        newEventModel.otherLinks = event.readHtmlLink()
        newEventModel.parent = event.isRecurrence ? event : nil
        newEventModel.recurringEventId = event.readRecurringEventId()
        if type != .thisPerticularEvent {
            newEventModel.recurrence = event.readPlanItRecurrance()?.readRule() ?? Strings.empty
        }
        newEventModel.dateEvent = self.dateEvent
        let visibilityCalendars = event.readAllEventCalendars()
        newEventModel.calendars = event.readAllAvailableCalendars(includingParent: true).map({ calendar in return UserCalendarVisibility(with: calendar, visibility: visibilityCalendars.contains( where: { return (($0.calendarId == calendar.calendarId && calendar.calendarId != 0) || ($0.appCalendarId == calendar.appCalendarId && !calendar.readValueOfAppCalendarId().isEmpty)) && $0.accessLevel == 1}) ? 1 : 0) })
        let notifyCalendars = event.readAllEventNotifyCalendars()
        newEventModel.notifycalendars = event.readAllAvailableNotifyCalendars().map({ calendar in return UserCalendarVisibility(with: calendar, visibility: notifyCalendars.contains( where: { return (($0.calendarId == calendar.calendarId && calendar.calendarId != 0) || ($0.appCalendarId == calendar.appCalendarId && !calendar.readValueOfAppCalendarId().isEmpty)) && $0.accessLevel == 0}) ? 0 : 1) })
        if  let reminder = event.reminder {
            newEventModel.remindValue = ReminderModel(reminder, from: .event)
        }
        newEventModel.invitees = event.readOtherUsers()
        if let latLong = event.readPlaceLatLong() {
            newEventModel.placeLatitude = latLong.0
            newEventModel.placeLongitude = latLong.1
        }
        if type == .allFutureEvent || type == .thisPerticularEvent {
            newEventModel.startDate = event.readStartDateTimeFromDate(self.dateEvent.startDate)
            newEventModel.endDate = event.readEndDateTimeFromDate(self.dateEvent.startDate)
        }
        else {
            newEventModel.startDate = event.readStartDateTime()
            newEventModel.endDate = event.readEndDateTime()
        }
        newEventModel.editType = type
        newEventModel.conferenecType = event.readconferenceType()
        newEventModel.conferenecUrl = event.readconferenceURL()
        newEventModel.fullConferenceData = event.readFullConferenceData()
        return newEventModel
    }
    
    func createEventModelFromOtherUserEvent(_ event: OtherUserEvent, type: RecursiveEditOption) -> MiPlanItEvent {
        if let eventId = Double(event.eventId), let planItEvent = DatabasePlanItEvent().readPlanItEventsWith(eventId) {
            return self.createEventModelFromPlantItEvent(planItEvent, type: type)
        }
        return MiPlanItEvent()
    }
    
    func isRecurrentEvent() -> Bool {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.isRecurrence
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.isRecurrence
        }
        return false
    }
    
    func isHTMLLinkAvailable() -> Bool {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.isHTMLContent()
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.isHTMLContent()
        }
        return false
    }
    
    func readAllTags() -> [String] {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.readAllTags().compactMap({ return $0.tag })
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.tags
        }
        return []
    }
    
    func createTextToPredict() -> String {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.createTextForPrediction()
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.createTextForPrediction()
        }
        return Strings.empty
    }
    
    func getDefaultTags() -> [String] {
        var defaultTag = ["Events"]
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            var calendarName = planItEvent.readEventCalendarName()
            if let mainCalendar = planItEvent.readMainCalendar() {
                calendarName = mainCalendar.parentCalendarId == 0.0 ? Strings.miPlaniT : calendarName
            }
            defaultTag.append(calendarName)
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            var calendarName = otherUserEvent.readEventCalendarName()
            if let mainCalendar = otherUserEvent.readMainCalendar() {
                calendarName = mainCalendar.parentCalendarId == 0.0 ? Strings.miPlaniT : calendarName
            }
            defaultTag.append(otherUserEvent.readEventCalendarName())
        }
        defaultTag = defaultTag.filter({ !$0.isEmpty })
        return defaultTag
    }
    
    func createStringForWebView() -> String {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.createStringForWebView()
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.createStringForWebView()
        }
        return Strings.empty
    }
    
    func isOtherUserType() -> Bool {
        return self.eventPlanOtherObject is OtherUserEvent
    }
    
    func readEventCreatedDate() -> Date? {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            return planItEvent.readStartDateTime().initialHour()
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            return otherUserEvent.readStartDateTime().initialHour()
        }
        return nil
    }
    
    func readRecurrentActionForEvent(isEdit:Bool, callBack: @escaping (Bool, RecursiveEditOption)->()) {
        if self.isRecurrentEvent() {
            self.showAlertWithAction(message: isEdit ? Message.editEventMessage : Message.eventDeleteMessage, title: isEdit ? Message.editEvent : Message.deleteEvent, items: [Message.editThisPerticularEvent, Message.editAllFutureEvent, Message.editThisSeriesEvent, Message.cancel], callback: { index in
                switch index {
                case 0:
                    callBack(true, .thisPerticularEvent)
                case 1:
                    callBack(true, .allFutureEvent)
                case 2:
                    callBack(true, .allEventInTheSeries)
                default:
                    callBack(false, .default)
                }
            })
        }
        else {
            if isEdit {
                callBack(true, .default)
            }
            else {
                self.showAlertWithAction(message: isEdit ? Message.editEventMessage : Message.eventDeleteMessage, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                    if index == 0 {
                        callBack(true, .default)
                    }
                    else {
                        callBack(false, .default)
                    }
                })
            }
        }
    }
    
    func readRecurrentCancelActionForEvent(callBack: @escaping (Bool, RecursiveEditOption)->()) {
        if self.isRecurrentEvent() {
            self.showAlertWithAction(message: Message.eventCancelMessage, title: Message.confirm, items: [Message.editThisPerticularEvent, Message.editAllFutureEvent, Message.editThisSeriesEvent, Message.cancel], callback: { index in
                switch index {
                case 0:
                    callBack(true, .thisPerticularEvent)
                case 1:
                    callBack(true, .allFutureEvent)
                case 2:
                    callBack(true, .allEventInTheSeries)
                default:
                    callBack(false, .default)
                }
            })
        }
        else {
            self.showAlertWithAction(message: Message.eventCancelMessage, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                if index == 0 {
                    callBack(true, .default)
                }
                else {
                    callBack(false, .default)
                }
            })
        }
    }
}
