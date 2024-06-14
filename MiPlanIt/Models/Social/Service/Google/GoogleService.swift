//
//  GoogleService.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class GoogleService {
    //TODO: Login details Fetch, like token and other user details
    func readCalendarEventsForUser(_ user: SocialUser, callback: @escaping ([SocialCalendar]?, Error?) -> ()) {
        userM = user
        let googleCommand = GoogleCommand()
        googleCommand.calendar(url: "users/me/calendarList", params: ["access_token": user.token], result: { response, error in
            if let calendar = response, let items = calendar["items"] as? [[String: Any]] {
                let ownerItems = items//.filter({ return ($0["accessRole"] as? String ?? Strings.empty) == "owner" })
                let socialCalendars = ownerItems.map({ return SocialCalendar(withGoogleData: $0, of: user) })
                callback(socialCalendars, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    
    func readEventsFromCalendar(_ calendar: SocialCalendar, pageToken: String = Strings.empty, callback: @escaping ([SocialCalendarEvent]?, Bool, Error?) -> ()) {
        let timeMin = Date().initialHour().addMonth(n: -1).stringFromDate(format: DateFormatters.YYYYHMMHDDTHHCMMCSSSZ)
        var params: [String: Any] = ["timeZone": "UTC", "timeMin": timeMin, "access_token": calendar.socialUser.token, "maxResults": 2000]
        if !pageToken.isEmpty { params["pageToken"] = pageToken }
        let googleCommand = GoogleCommand()
        let encoded = calendar.calendarId.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? Strings.empty
        googleCommand.calendar(url: "calendars/\(encoded)/events", params: params, result: { response, error in
            if let event = response, let items = event["items"] as? [[String: Any]] {
                let socialCalendarEvents = items.map({ return SocialCalendarEvent(withGoogleEvent: $0) })
                if let nextPageToken = event["nextPageToken"] as? String, !nextPageToken.isEmpty {
                    callback(socialCalendarEvents, false, nil)
                    self.readEventsFromCalendar(calendar, pageToken: nextPageToken, callback: callback)
                }
                else {
                    callback(socialCalendarEvents, true, nil)
                }
            }
            else {
                callback(nil, true, error)
            }
        })
    }
    
    func refreshToken(_ user: SocialUser, callback: @escaping (SocialUser, Error?) -> ()) {
        let googleCommand = GoogleCommand()
        let expirationDate = Date()
        googleCommand.refreshToken(params: ["client_id": ConfigureKeys.googleClientKey, "refresh_token": user.refreshToken, "grant_type": "refresh_token"], result: { response, error in
            if let result = response, let token = result["access_token"] as? String, let seconds = result["expires_in"] as? Int {
                user.token = token
                user.expiryTokenDate = expirationDate.adding(seconds: seconds).stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!)
            } else { user.expiryTokenDate = Strings.empty }
            callback(user, error)
        })
    }
}

class GoogleCommand: SocialService {
    
    func calendar(url: String, params: [String: Any], result: @escaping ([String: Any]?, Error?) -> ()) {
        self.googleService(url: url, method: .get, params: params, completionHandler: { response, error in
            if let data = response as? [String: Any] {
                result(data, nil)
            }
            else {
                result(nil, error)
            }
        })
    }
    
    func refreshToken(params: [String: Any], result: @escaping ([String: Any]?, Error?) -> ()) {
        self.googleRefreshToken(method: .post, params: params, completionHandler: { response, error in
            if let data = response as? [String: Any] {
                result(data, nil)
            }
            else {
                result(nil, error)
            }
        })
    }
}
