//
//  CalendarService.swift
//  MiPlanIt
//
//  Created by Arun on 27/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarService {
    
    private func getDateBySocialType(userType: UserType?, startDate: String) -> String? {
        var stringDate: String?
        switch userType {
        case .eGoogleUser?:
            if let date = startDate.toDateStrimg(withFormat: DateFormatters.YYYYHMMHDDTHHCMMCSSSZ) {
                stringDate = date.stringFromDate(format: DateFormatters.HHCMMCSS)
            }
        case .eOutlookUser?:
            if let date = startDate.toDateStrimg(withFormat: DateFormatters.YYYYHMMHDDTHHCMMCSSSDSSS) {
                stringDate = date.stringFromDate(format: DateFormatters.HHCMMCSS)
            }
        default:
            if let date = startDate.toDateStrimg(withFormat: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ) {
                stringDate = date.stringFromDate(format: DateFormatters.HHCMMCSS)
            }
        }
        return stringDate
    }
    
    private func readReminderNumericValueParameter(calendarEvent: SocialCalendarEvent, socialUser: SocialUser?) -> [String: Any]? {
        var remimderParameter: [String: Any] = [:]
        remimderParameter["intrvl"] = calendarEvent.readReminderBeforeMinutesValue()
        remimderParameter["intrvlType"] = "1"
        remimderParameter["emailNotification"] = false
        remimderParameter["emailNotificationBody"] = Strings.empty
        return remimderParameter
    }
    
    private func readAllAvailableCalendarsColorCode() -> [String] {
        let calendars = DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.calendarType == 0 || $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
        return calendars.compactMap({ $0.calendarColorCode })
    }
    
    private func createParamsForUser(calendars: [SocialCalendar], appliedColorCodes: [ColorCode]) -> ([String: Any], [ColorCode]) {
        var calendarDetails: [String: Any] = ["userId": Session.shared.readUserId()]
        var bindingCalendars: [[String: Any]] = []
        var index = 0
        let availableColorCodes = Storage().getAllColorCodes()
        let appliedColorCodeObjects = appliedColorCodes
        
        var addedColorCode: [ColorCode] = []
        calendars.forEach({ calendar in
            
            var colorCode: ColorCode!
            if let nonAddedColor = availableColorCodes.difference(from: appliedColorCodeObjects + addedColorCode).sorted(by: { $0.order < $1.order }).first, !nonAddedColor.isDefault {
                colorCode = nonAddedColor
            }
            else if let leastOccuranceColor = (appliedColorCodeObjects + availableColorCodes).difference(from: addedColorCode).sortByNumberOfOccurences().sorted(by: { $0.order < $1.order }).first {
                colorCode = leastOccuranceColor
            }
            else {
                let storedColorCode = Storage().getRandomColorCode() ?? Storage().getDefaultColorCodes()
                colorCode = storedColorCode
            }
            addedColorCode.append(colorCode)
            var calendarData: [String: Any] = ["calendar_id": calendar.calendarId, "calendar_name": calendar.calendarName, "canEdit": calendar.canEdit, "calColourCode": colorCode.readColorCodeKey()]
            var calendarEvents: [[String: Any]] = []
            let parentChildEvents = calendar.readAllParentChildEvents()
            for event in parentChildEvents.parent {
                var eventParams: [String: Any] = ["eventId": event.eventId, "eventName": event.eventName, "event_description": event.eventDescription, "isAllDay": event.allday, "created_date": event.createdDate, "updated_date": event.updatedDate, "location": event.location, "event_start_date": event.startDate, "event_end_date": event.endDate, "originalStartTimeZone": event.originalStartTimeZone, "originalEndTimeZone": event.originalEndTimeZone, "organizerEmail": event.organizerEmail, "organizerName": event.organizerName, "creatorEmail": event.creatorEmail, "creatorName": event.creatorName, "status": event.status, "recurrence": event.recurrenceRule, "recurringEventId": event.recurringEventId, "originalStartTime": event.originalStartTime, "outlookBodyContent": event.outlookBodyContent, "outlookBodyContentType": event.outlookBodyContentType, "htmlLink": event.htmlLink, "attendees": event.attendees, "attachments": event.attachments, "excludedDates": event.excludedDates]
                if event.remindMeBeforeMinutes != nil {
                    eventParams["reminders"] = self.readReminderNumericValueParameter(calendarEvent: event, socialUser: calendar.socialUser)
                }
                if !event.conferenceData.isEmpty {
                    eventParams["conferenceData"] = event.conferenceData
                }
                eventParams["responseStatus"] = event.responseStatus
                if let child = parentChildEvents.child[event.eventId], !child.isEmpty {
                    eventParams["child"] = child.compactMap({ childEvent -> [String: Any] in
                        var childRequestParams: [String: Any] =  ["eventId": childEvent.eventId, "eventName": childEvent.eventName, "event_description": childEvent.eventDescription, "isAllDay": childEvent.allday, "isOriginalAllDay": childEvent.isOriginalAllDay, "created_date": childEvent.createdDate, "updated_date": childEvent.updatedDate, "location": childEvent.location, "event_start_date": childEvent.startDate, "event_end_date": childEvent.endDate, "originalStartTimeZone": event.originalStartTimeZone, "originalEndTimeZone": event.originalEndTimeZone, "organizerEmail": childEvent.organizerEmail, "organizerName": childEvent.organizerName, "creatorEmail": childEvent.creatorEmail, "creatorName": childEvent.creatorName, "status": childEvent.status, "recurrence": childEvent.recurrenceRule, "recurringEventId": childEvent.recurringEventId, "originalStartTime": childEvent.originalStartTime, "outlookBodyContent": childEvent.outlookBodyContent, "outlookBodyContentType": childEvent.outlookBodyContentType, "htmlLink": childEvent.htmlLink, "attendees": childEvent.attendees, "attachments": childEvent.attachments]
                        if childEvent.remindMeBeforeMinutes != nil {
                            childRequestParams["reminders"] = self.readReminderNumericValueParameter(calendarEvent: childEvent, socialUser: calendar.socialUser)
                        }
                        if !childEvent.conferenceData.isEmpty {
                            childRequestParams["conferenceData"] = childEvent.conferenceData
                        }
                        childRequestParams["responseStatus"] = childEvent.responseStatus
                        return childRequestParams
                    })
                }
                calendarEvents.append(eventParams)
            }
            calendarData["deletedEvents"] = calendar.deletedEvents
            calendarData["events"] = calendarEvents
            bindingCalendars.append(calendarData)
            index += 1
        })
        let userId = calendars.first?.socialUser?.userId ?? Strings.empty
        let email = calendars.first?.socialUser?.email ?? Strings.empty
        let name = calendars.first?.socialUser?.fullName ?? Strings.empty
        let token = calendars.first?.socialUser?.token ?? Strings.empty
        let refreshToken = calendars.first?.socialUser?.refreshToken ?? Strings.empty
        let accessTokenExpirationDate = calendars.first?.socialUser?.expiryTokenDate ?? Strings.empty
        let userKey = calendars.first?.socialUser?.userType == .eGoogleUser ? "Google" : calendars.first?.socialUser?.userType == .eOutlookUser ? "Outlook" : "Apple"
        calendarDetails["calendarData"] = [[userKey: ["token": token, "refreshToken": refreshToken, "accessTokenExpirationDate": accessTokenExpirationDate, "user": userId, "socialAccountEmail": email, "socialAccountName": name, "calendars": bindingCalendars]]]
        return (calendarDetails, addedColorCode)
    }
    
    func importUser(calendars: [SocialCalendar], appliedColorCodes: [ColorCode] = [], callback: @escaping (Bool, [ColorCode], String?) -> ()) {
        let calendarCommand = CalendarCommand()
        let (params, colorCodes) = self.createParamsForUser(calendars: calendars, appliedColorCodes: appliedColorCodes)
        calendarCommand.importCalendar(params, callback: { result, error in
            if let status = result {
                Session.shared.saveSocialCalendarFetchStatus(true)
                let allAddedColorCodes = Array(Set(colorCodes+appliedColorCodes))
                callback(status, allAddedColorCodes, error)
            }
            else {
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    func syncUsers(_ socialUsers: [SocialUser], callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        let users: [[String: Any]] = socialUsers.map({ return ["socialAccountId": $0.userId, "socialAccType": $0.userType == .eOutlookUser ? 2 : 1, "token": $0.token, "socialAccountName": $0.fullName, "socialAccountEmail": $0.email, "refreshToken": $0.refreshToken, "accessTokenExpirationDate": $0.expiryTokenDate]})
        calendarCommand.syncUsers(["userId": Session.shared.readUserId(), "tokens": users], callback: { result, error in
            if let status = result {
                callback(status, error)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        })
    }
    
    func socialCalendarUsers(callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.socialCalendarUsers(["userId": Session.shared.readUserId()], callback: { response, error in
            if let result = response, let users = result["socialCalendars"] as? [[String: Any]] {
                DatabasePlanItSocialUser().insertSocialUsers(users, result: { expireOn in
                    Session.shared.readUser()?.saveSocialAccountExpirationDate(expireOn)
                    callback(true, error)
                })
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        })
    }
    
    func fetchUsersCalendarServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        let calendarCommand = CalendarCommand()
        Session.shared.saveUsersCalendarDataFetching(true)
        Session.shared.saveUsersCalendarOnlyDataFetching(true)
        calendarCommand.usersCalendarData(["userId": user.readValueOfUserId(), "lastSyncDate": ""], callback: { result, error in
            if let data = result {
                DatabasePlanItData().insertPlanItUserDataForCalendar(data, callback: { lastSyncTime, serviceDetection in
                    if let count = data["count"] as? Double { user.saveNotificationCount(count) }
                    user.readUserSettings().saveLastCalendarFetchDataTime(lastSyncTime)
                    Session.shared.saveSocialCalendarFetchStatus(false)
                    Session.shared.saveUsersCalendarDataFetching(false)
                    Session.shared.saveUsersCalendarOnlyDataFetching(false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: serviceDetection)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersCalendarDataFetching(false)
                Session.shared.saveUsersCalendarOnlyDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    func fetchUsersShareLinkServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        let calendarCommand = CalendarCommand()
        Session.shared.saveUsersShareLinkDataFetching(true)
        calendarCommand.usersShareLinkData(["userId": user.readValueOfUserId(), "lastSyncDate": user.readUserSettings().readLastShareListFetchDataTime()], callback: { result, error in
            if let data = result {
                DatabasePlanItData().insertPlanItUserDataForShareLink(data, callback: { lastSyncTime, serviceDetection in
                    if let count = data["count"] as? Double { user.saveNotificationCount(count) }
                    user.readUserSettings().saveLastEventShareLinkFetchDataTime(lastSyncTime)
                    Session.shared.saveUsersShareLinkDataFetching(true)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersShareLinkDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    func deleteEventShareLink(_ shareLink: PlanItShareLink, callback: @escaping (PlanItShareLink?, String?) -> ()) {
        let shopCommand = ShopCommand()
        let requestParams: [String: Any] = ["userId": Session.shared.readUserId(), "calBookLinkIds": [Int(Double(shareLink.readEventShareLinkId()) )]]
        shopCommand.deleteShareLink(requestParams) { (status, error) in
            if status {
                let shareLinkObj = DatabasePlanItShareLink().deleteSpecificShareLink(shareLink.shareLinkId)
                callback(shareLinkObj, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func fetchOtherUserEvents(_ users: [CalendarUser], callback: @escaping ([OtherUser]?, String?) -> ()) {
        let userIds = users.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId] })
        let emails = users.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email, "fullName": $0.name] })
        let phones = users.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "fullName": $0.name, "countryCode": $0.countryCode] })
        let selUsers = userIds + emails + phones
        let eventDateFrom = Date().adding(days: -7).stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        let calendarCommand = CalendarCommand()
        calendarCommand.otherUsersEvent(["userId": Session.shared.readUserId(), "eventDateFrom": eventDateFrom, "selUsers": selUsers], callback: { response, error in
            if let result = response {
                var otherUsers: [OtherUser] = []
                let storedColorCodes: [String] = Storage().getColorCodes().compactMap({ $0.readColorCodeKey() })
                if let events = result["UserEvents"] as? [[String: Any]] {
                    var index = -1
                    otherUsers.append(contentsOf: events.map({ index += 1; return OtherUser(with: $0, contains: users, colors: storedColorCodes, index: index) }))
                }
                if let nonExistingUsers = result["nonExistingUsers"] as? [[String: Any]], !nonExistingUsers.isEmpty {
                    var index = -1
                    otherUsers += nonExistingUsers.map({ index += 1; return OtherUser(with: $0, colors: storedColorCodes, index: index) })
                }
                callback(otherUsers, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func fetchOtherUserEvents(_ users: [PlanItInvitees], of calendars: [UserCalendarVisibility], callback: @escaping ([OtherUser]?, String?) -> ()) {
        var userIds = users.map({ return ["userId": $0.readValueOfUserId()] })
        calendars.forEach({ if let calendarUser = $0.calendar.createdBy?.readValueOfUserId(), Session.shared.readUserId() != calendarUser { userIds.append(["userId": calendarUser]) } })
        let eventDateFrom = Date().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        let calendarCommand = CalendarCommand()
        calendarCommand.otherUsersEvent(["userId": Session.shared.readUserId(), "eventDateFrom": eventDateFrom, "selUsers": userIds], callback: { response, error in
            if let result = response, let events = result["UserEvents"] as? [[String: Any]] {
                let storedColorCodes: [String] = Storage().getColorCodes().compactMap({ $0.readColorCodeKey() })
                var indexColor: Int = -1
                let otherUsersEvent = events.filter({ return ($0["userId"] as? Double)?.cleanValue() != Session.shared.readUserId() }).map { (item) -> OtherUser in
                    indexColor += 1
                    return OtherUser(with: item, contains: users, colors: storedColorCodes, index: indexColor)
                }
                callback(otherUsersEvent, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func addEditNewCalendar(_ calendar: NewCalendar, callback: @escaping (PlanItCalendar?, String?) -> ()) {
        let fullUserIds = calendar.fullAccesUsers.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId, "accessLevel": 2] })
        let fullEmails = calendar.fullAccesUsers.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email, "accessLevel": 2] })
        let fullPhones = calendar.fullAccesUsers.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "accessLevel": 2, "countryCode": $0.countryCode] })
        let partialUserIds = calendar.partailAccesUsers.filter({ return !$0.userId.isEmpty  }).map({ return ["userId": $0.userId, "accessLevel": 1] })
        let partialEmails = calendar.partailAccesUsers.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email, "accessLevel": 1] })
        let partialPhones = calendar.partailAccesUsers.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "accessLevel": 1, "countryCode": $0.countryCode] })
        let notifyUserIds = calendar.notifyUsers.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId, "accessLevel": 1, "isNotifyCalendar": true] })
        let notifyEmails = calendar.notifyUsers.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email, "accessLevel": 1, "isNotifyCalendar": true] })
        let notifyPhones = calendar.notifyUsers.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "accessLevel": 1, "countryCode": $0.countryCode, "isNotifyCalendar": true] })
        let selUsers = fullUserIds + fullEmails + fullPhones + partialUserIds + partialEmails + partialPhones + notifyUserIds + notifyEmails + notifyPhones
        let calendarCommand = CalendarCommand()
        var calendarParams: [String : Any] = ["userId": Session.shared.readUserId(), "calendarName": calendar.name, "invitees": selUsers, "createdAt": Date().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!), "calColourCode": calendar.calendarColorCode, "appCalendarId": calendar.appCalendarId]
        if let plantItCalendarId = calendar.planItCalendar?.readValueOfCalendarId(), !plantItCalendarId.isEmpty {
            calendarParams["calendarId"] = plantItCalendarId
        }
        calendarCommand.newCalendar(calendarParams, callback: { response, error in
            if let result = response, !result.isEmpty {
                if let plantItCalendar = calendar.planItCalendar {
                    let newPlantItCalendar = DatabasePlanItCalendar().updateCalendar(plantItCalendar, withNewCalendar: result)
                    Session.shared.loadFastestCalendars()
                    callback(newPlantItCalendar, nil)
                }
                else {
                    let plantItCalendar = DatabasePlanItCalendar().insertNewPlanItCalendars([result]).first
                    Session.shared.loadFastestCalendars()
                    callback(plantItCalendar, nil)
                }
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func uploadCalendarImages(_ calendar: PlanItCalendar, file: String, name: String, by owner: PlanItUser, callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.uploadCalendarPic(["calendarId": calendar.readValueOfCalendarId(), "fileName": name, "fileData": file, "userId": calendar.readOwnerUserId()]) { (response, error) in
            if let result = response, let image = result["calImage"] as? String {
                calendar.saveCalendarImage(image)
                callback(true, nil)
            }
            else {
                callback(false, error)
            }
        }
    }
    
    func addEvent(event: MiPlanItEvent, isUpdateTagsOnly tagOnly: Bool = false, callback: @escaping ([Any]?, [String]?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        let requestParams = event.createRequestParameter(isUpdateTagsOnly: tagOnly)
        calendarCommand.createEvent(requestParams) { (response, error) in
            if let result = response, let events = result["events"] as? [[String: Any]] {
                let removedEvents = result["removedEvents"] as? [Double]
                let eventInserted = DatabasePlanItEvent().insertUpdate(events, deletedEvents: removedEvents)
                let mappedRemovedEvent = removedEvents?.map({ return $0.cleanValue() })
                Session.shared.registerUserEventLocationNotification()
                if event.isOtherUserEvent {
                    let otherUserEvents = events.map({ return OtherUserEvent(with: $0, user: Session.shared.readUserId()) })
                    callback(otherUserEvents, mappedRemovedEvent, nil)
                }
                else {
                    callback(eventInserted, mappedRemovedEvent, nil)
                }
            }
            else {
                callback(nil, nil, error ?? Message.unknownError)
            }
        }
    }
    

    func offlineAddEditEvents(events: [String: Any], callback: @escaping ([Any]?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.createEvent(events) { (response, error) in
            if let result = response, let events = result["events"] as? [[String: Any]] {
                let eventInserted = DatabasePlanItEvent().insertUpdate(events, deletedEvents: result["removedEvents"] as? [Double])
                Session.shared.registerUserEventLocationNotification()
                callback(eventInserted, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func deleteEvent(_ event: PlanItEvent, request: [String: Any], deleteType: RecursiveEditOption, isOtherUser: Bool, callback: @escaping (Bool, [Any]?, [String]?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.deleteEvent(request) { (response, status, error) in
            if status {
                if let result = response, let events = result["events"] as? [[String: Any]] {
                    let removedEvents = result["removedEvents"] as? [Double]
                    let eventInserted = DatabasePlanItEvent().insertUpdate(events, deletedEvents: removedEvents)
                    let mappedRemovedEvent = removedEvents?.map({ return $0.cleanValue() })
                    Session.shared.registerUserEventLocationNotification()
                    if isOtherUser {
                        let otherUserEvents = events.map({ return OtherUserEvent(with: $0, user: Session.shared.readUserId()) })
                        callback(true, otherUserEvents, mappedRemovedEvent, nil)
                    }
                    else  {
                        callback(true, eventInserted, mappedRemovedEvent, nil)
                    }
                }
                else {
                    let childEvents = event.readAllChildEvents()
                    Session.shared.removeNotification(LocalNotificationMethod.event.rawValue + event.readValueOfNotificationId())
                    event.deleteItSelf()
                    callback(true, childEvents, nil, nil)
                }
            }
            else {
                callback(false, nil, nil, error ?? Message.unknownError)
            }
        }
    }
    
    func deleteOfflineEvents(request: [String: Any], callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.deleteEvent(request) { (response, status, error) in
            if status {
                if let result = response, let events = result["events"] as? [[String: Any]] {
                    let _ = DatabasePlanItEvent().insertUpdate(events, deletedEvents: result["removedEvents"] as? [Double])
                    Session.shared.registerUserEventLocationNotification()
                    callback(true, nil)
                }
                else {
                    callback(true, nil)
                }
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func cancelEvent(_ event: PlanItEvent, request: [String: Any], deleteType: RecursiveEditOption, isOtherUser: Bool, callback: @escaping (Bool, [Any]?, [String]?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.cancelEvent(request) { (response, status, error) in
            if status {
                 if let result = response, let events = result["events"] as? [[String: Any]] {
                    let removedEvents = result["removedEvents"] as? [Double]
                    let eventInserted = DatabasePlanItEvent().insertUpdate(events, deletedEvents: removedEvents)
                    let mappedRemovedEvent = removedEvents?.map({ return $0.cleanValue() })
                    Session.shared.registerUserEventLocationNotification()
                    if isOtherUser {
                        let otherUserEvents = events.map({ return OtherUserEvent(with: $0, user: Session.shared.readUserId()) })
                        callback(true, otherUserEvents, mappedRemovedEvent, nil)
                    }
                    else  {
                        callback(true, eventInserted, mappedRemovedEvent, nil)
                    }
                 }
                 else {
                    Session.shared.removeNotification(LocalNotificationMethod.event.rawValue + event.readValueOfNotificationId())
                     event.deleteItSelf()
                     callback(true, nil, nil, nil)
                 }
            }
            else {
                callback(false, nil, nil, error ?? Message.unknownError)
            }
        }
    }
    
    func cancelOfflineEvents(request: [String: Any], callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.cancelEvent(request) { (response, status, error) in
            if status {
                if let result = response, let events = result["events"] as? [[String: Any]] {
                    let _ = DatabasePlanItEvent().insertUpdate(events, deletedEvents: result["removedEvents"] as? [Double])
                    Session.shared.registerUserEventLocationNotification()
                    callback(true, nil)
                }
                 else {
                     callback(true, nil)
                 }
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func deleteCalendar(_ calendar: PlanItCalendar, callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.deleteCalendar(["userId": Session.shared.readUserId(), "calendarId": calendar.readValueOfCalendarId()]) { (response, error) in
            if let status = response, status {
                Session.shared.removeCalendarNotification(calendar.readValueOfCalendarId())
                Session.shared.removeEventFromFastestEventOfCalendar(calendar.readValueOfCalendarId())
                DatabasePlanItEvent().removedPlantItEventsFromCalendar(calendar)
                calendar.deleteItSelf()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    func deleteShareCalendar(_ calendar: PlanItCalendar, callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.deleteSharedCalendar(["userId": Session.shared.readUserId(), "calendarId": calendar.readValueOfCalendarId(),"cal_type":"shared"]) { (response, error) in
            if let status = response, status {
                Session.shared.removeCalendarNotification(calendar.readValueOfCalendarId())
                Session.shared.removeEventFromFastestEventOfCalendar(calendar.readValueOfCalendarId())
                DatabasePlanItEvent().removedPlantItEventsFromCalendar(calendar)
                calendar.deleteItSelf()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
//    func deleteDefaultShareCalendar(_ calendar: PlanItCalendar, callback: @escaping (Bool, String?) -> ()) {
//        let calendarCommand = CalendarCommand()
//        calendarCommand.deleteCalendar(["userId": Session.shared.readUserId(), "calendarId": calendar.readValueOfCalendarId(),"cal_type":""]) { (response, error) in
//            if let status = response, status {
//                Session.shared.removeCalendarNotification(calendar.readValueOfCalendarId())
//                Session.shared.removeEventFromFastestEventOfCalendar(calendar.readValueOfCalendarId())
//                DatabasePlanItEvent().removedPlantItEventsFromCalendar(calendar)
//                calendar.deleteItSelf()
//                callback(true, nil)
//            }
//            else {
//                callback(false, error ?? Message.unknownError)
//            }
//        }
//    }

    
    func userCalendarSync(_ calendarType: String, callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        var params: [String: Any] = [:]
        if calendarType.isEmpty { params = ["userId": Session.shared.readUserId(), "silentNotification": 1] }
        else { params = ["userId": Session.shared.readUserId(), "calendarType": calendarType] }
        calendarCommand.syncCalendar(params) { (response, error) in
            if let status = response, status {
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func setDefaultCalendarShare(calendar: PlanItCalendar, invitees: CalendarInvitees, callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        var parameterProperty: [String: Any] = [:]
        parameterProperty["calendarId"] = calendar.calendarId
        var userDict: [[String: Any]] = []
        invitees.fullAccesUsers.forEach { (user) in
            var sharedUser: [String: Any] = [:]
            if user.userId != Strings.empty {
                sharedUser["userId"] = user.userId
            }
            else if user.email != Strings.empty {
                sharedUser["email"] = user.email
            }
            else if user.phone != Strings.empty {
                sharedUser["phone"] = user.phone
            }
            sharedUser["visibility"] = 0
            userDict.append(sharedUser)
        }
        invitees.partailAccesUsers.forEach { (user) in
            var sharedUser: [String: Any] = [:]
            if user.userId != Strings.empty {
                sharedUser["userId"] = user.userId
            }
            else if user.email != Strings.empty {
                sharedUser["email"] = user.email
            }
            else if user.phone != Strings.empty {
                sharedUser["phone"] = user.phone
            }
            sharedUser["visibility"] = 1
            userDict.append(sharedUser)
        }
        parameterProperty["userId"] = Session.shared.readUserId()
        parameterProperty["sharedTo"] = userDict
        let parameter: [String: Any] = ["defaultCalendarShare": [parameterProperty]]
        calendarCommand.shareCalendar(parameter) { (response, error) in
            if let status = response, status {
                DatabasePlanItCalendar().updateCalendarSharedUser(calendar, withInvitees: invitees)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func getDefaultCalendarSharedUsers(callback: @escaping ([CalendarUser]?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        let parameterProperty: [String: Any] = ["listDefaultCalendarSharedUsers": [["userId": Session.shared.readUserId()]]]
        calendarCommand.getDefaultShareUser(parameterProperty) { (response, error) in
            if let result = response, let sharedUsers = result["sharedUsers"] as? [[String: Any]] {
                callback(sharedUsers.map({ CalendarUser($0) }), nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func outlookDeletedEvents(callback: @escaping (Bool, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        calendarCommand.deletedOutlookEvent(["userId": Session.shared.readUserId()], callback: { result, error in
            callback(result, error)
        })
    }
    
    func addShareLink(shareLink: MiPlanitShareLink, callback: @escaping (Bool?, String?) -> ()) {
        let calendarCommand = CalendarCommand()
        let requestParams = shareLink.createRequestParameter()
        calendarCommand.createShareLink(requestParams) { (response, warning, error) in
            if let result = response {
                DatabasePlanItShareLink().insertPlanItShareLink(result)
                callback(true, nil)
            }
            else {
                if let warningMsg = warning, !warningMsg.isEmpty, let planItShareLink = shareLink.planItShareLink {
                    planItShareLink.updateShareLinkWithWarning(warningMsg)
                }
                callback(false, error ?? warning ?? Message.unknownError)
            }
        }
    }
}

class CalendarCommand: WSManager {
    
    func importCalendar(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.importCalendar, params: params, callback: { response, error in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func syncUsers(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.syncSocialUser, params: params, callback: { response, error in
            if let result = response {
                callback(result.isSuccessful() || result.error == "No Data to update", result.error)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    //test:
    func socialCalendarUsers(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.socialCalendarUsers, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func usersCalendarData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.calendarFetch, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func usersShareLinkData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.shareLinkFetch, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func otherUsersEvent(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.calendarEvents, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func newCalendar(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.addCalendar, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func uploadCalendarPic(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.uploadCalendarImage, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func createEvent(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.createEvent, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func cancelEvent(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, Bool, String?) -> ()) {
        self.post(endPoint: ServiceData.eventCancel, params: params) { (response, error) in
            if let result = response {
                if result.success {
                    if let data = result.data as? [[String: Any]], let details = data.first {
                        callback(details, true, nil)
                    }
                    else {
                        callback(nil, true, nil)
                    }
                }
                else {
                    callback(nil, false, result.error)
                }
            }
            else {
                callback(nil, false, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func deleteEvent(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, Bool, String?) -> ()) {
        self.delete(endPoint: ServiceData.eventDelete, params: params) { (response, error) in
            if let result = response {
                if result.success {
                    if let data = result.data as? [[String: Any]], let details = data.first {
                        callback(details, true, nil)
                    }
                    else {
                        callback(nil, true, nil)
                    }
                }
                else {
                    callback(nil, false, result.error)
                }
            }
            else {
                callback(nil, false, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func deleteSharedCalendar(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.deleteSharedCalendarInvitee, params: params) { (response, error) in//my calendar
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func deleteCalendar(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.delete(endPoint: ServiceData.calendarDelete, params: params) { (response, error) in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func syncCalendar(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.get(endPoint: ServiceData.syncCalendar, params: params) { (response, error) in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
//                callback(nil, error?.message ?? Message.unknownError)
                callback(true, nil)
            }
        }
    }
    
    func shareCalendar(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.calendarDefaultShare, params: params) { (response, error) in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func getDefaultShareUser(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.calendarDefaultShareUsers, params: params) { (response, error) in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func deletedOutlookEvent(_ params: [String: Any]?, callback: @escaping (Bool, String?) -> ()) {
        self.get(endPoint: ServiceData.deletedOutlookInstances, params: params) { (response, error) in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(false, nil)
            }
        }
    }
    
    func createShareLink(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?, String?) -> ()) {
        self.post(endPoint: ServiceData.createShareLink, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil, nil)
                }
                else {
                    callback(nil, result.error, nil)
                }
            }
            else {
                callback(nil, nil, error?.message ?? Message.unknownError)
            }
        })
    }
}

