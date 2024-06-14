//
//  OutlookService.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MSGraphClientSDK

class OutlookService {
    
    func readCalendarEventsForUser(_ user: SocialUser, callback: @escaping ([SocialCalendar]?, Error?) -> ()) {
        let command = OutlookCommand()
        guard let client = MSClientFactory.createHTTPClient(with: OutlookAuthenticationManager(with: user.token)) else { return }
        command.calendar(url: "/me/calendars", client: client, result: { response, nextLink, error in
            if let calenders = response {
                let socialCalendars = calenders.map({ SocialCalendar(withOutlookData: $0, of: user) })
                if let nextPage = nextLink, !nextPage.isEmpty, !socialCalendars.isEmpty {
                    self.readNextLinkOfUserCalnder(user, calendars: socialCalendars, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    callback(socialCalendars, nil)
                }
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func readNextLinkOfUserCalnder(_ user: SocialUser, calendars: [SocialCalendar], client: MSHTTPClient, pageLink: String, callback: @escaping ([SocialCalendar]?, Error?) -> ()) {
        let pageURL = pageLink.replacingOccurrences(of: MSGraphBaseURL, with: Strings.empty)
        let command = OutlookCommand()
        command.calendar(url: pageURL, client: client, result: { response, nextLink, error in
            if let newCalenders = response {
                let socialCalendars = calendars + newCalenders.map({ SocialCalendar(withOutlookData: $0, of: user) })
                if let nextPage = nextLink, !nextPage.isEmpty, !newCalenders.isEmpty {
                    self.readNextLinkOfUserCalnder(user, calendars: socialCalendars, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    callback(socialCalendars, nil)
                }
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func readEventsOfCalendar(_ calendar: SocialCalendar, callback: @escaping ([[String: Any]]?, Bool, Error?) -> ()) {
        let command = OutlookCommand()
        guard let client = MSClientFactory.createHTTPClient(with: OutlookAuthenticationManager(with: calendar.socialUser.token)) else { return }
        let timeMin = Date().initialHour().addMonth(n: -1).stringFromDate(format: DateFormatters.YYYYHMMHDDTHHCMM)
        let encodedQuery = "?$top=100&$filter = type eq 'seriesMaster' or end/dateTime ge '\(timeMin)'".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? Strings.empty
        command.calendar(url: "/me/calendars/\(calendar.calendarId)/events" + encodedQuery, client: client, result: { response, nextLink, error in
            if let events = response {
                callback(events, false, nil)
                if let nextPage = nextLink, !nextPage.isEmpty, !events.isEmpty {
                    self.readNextLinkOfSeriesCalnderEvents(calendar, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    self.readExceptionEventsOfCalendar(calendar, client: client, callback: callback)
                }
            }
            else {
                callback(nil, true, error)
            }
        })
    }
    
    func readNextLinkOfSeriesCalnderEvents(_ calendar: SocialCalendar, client: MSHTTPClient, pageLink: String, callback: @escaping ([[String: Any]]?, Bool, Error?) -> ()) {
        let pageURL = pageLink.replacingOccurrences(of: MSGraphBaseURL, with: Strings.empty)
        let command = OutlookCommand()
        command.calendar(url: pageURL, client: client, result: { response, nextLink, error in
            if let newEvents = response {
                callback(newEvents, false, nil)
                if let nextPage = nextLink, !nextPage.isEmpty, !newEvents.isEmpty {
                    self.readNextLinkOfSeriesCalnderEvents(calendar, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    self.readExceptionEventsOfCalendar(calendar, client: client, callback: callback)
                }
            }
            else {
                callback(nil, true, error)
            }
        })
    }
    
    func readExceptionEventsOfCalendar(_ calendar: SocialCalendar, client: MSHTTPClient, callback: @escaping ([[String: Any]]?, Bool, Error?) -> ()) {
        let command = OutlookCommand()
        let minDate = Date().initialHour().addMonth(n: -1).stringFromDate(format: DateFormatters.YYYYHMMHDDTHHCMMCSSS)
        let maxDate = Date().initialHour().addMonth(n: 6).stringFromDate(format: DateFormatters.YYYYHMMHDDTHHCMMCSSS)
        let encodedQuery = "?startDateTime=\(minDate)&endDateTime=\(maxDate)&$top=100&$filter = type eq 'exception' or type eq 'occurrence'".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? Strings.empty
        command.calendar(url: "/me/calendars/\(calendar.calendarId)/calendarView" + encodedQuery, client: client, result: { response, nextLink, error in
            if let newEvents = response {
                if let nextPage = nextLink, !nextPage.isEmpty, !newEvents.isEmpty {
                    callback(newEvents, false, nil)
                    self.readNextLinkOfExceptionCalnderEvents(calendar, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    callback(newEvents, true, nil)
                }
            }
            else {
                callback(nil, true, error)
            }
        })
    }
    
    func readNextLinkOfExceptionCalnderEvents(_ calendar: SocialCalendar, client: MSHTTPClient, pageLink: String, callback: @escaping ([[String: Any]]?, Bool, Error?) -> ()) {
        let pageURL = pageLink.replacingOccurrences(of: MSGraphBaseURL, with: Strings.empty)
        let command = OutlookCommand()
        command.calendar(url: pageURL, client: client, result: { response, nextLink, error in
            if let newEvents = response {
                if let nextPage = nextLink, !nextPage.isEmpty, !newEvents.isEmpty {
                    callback(newEvents, false, nil)
                    self.readNextLinkOfExceptionCalnderEvents(calendar, client: client, pageLink: nextPage, callback: callback)
                }
                else {
                    callback(newEvents, true, nil)
                }
            }
            else {
                callback(nil, true, error)
            }
        })
    }
    
    fileprivate func getAccessTokenFromRefreshToken(_ refreshToken: String, redirectUrl: String, callback: @escaping ([String: Any]?, Error?) -> ()) {
        var params: [String: Any] = [:]
        params["grant_type"] = "refresh_token"
        params["client_secret"] = ConfigureKeys.outlookSecretKey
        params["redirect_uri"] = redirectUrl
        params["refresh_token"] = refreshToken
        params["scope"] = ServiceData.outlookScopes.joined(separator: " ")
        params["client_id"] = ConfigureKeys.outlookClientId
        OutlookCommand().getMicrosoftLoginToken(params: params) { (result, error) in
            if let data = result, error == nil {
                callback(data, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
    
    func getMicrosoftLoginToken(_ code: String, redirectUrl: String, callback: @escaping ([String: Any]?, Error?) -> ()) {
        var params: [String: Any] = [:]
        params["grant_type"] = "authorization_code"
        params["client_id"] = ConfigureKeys.outlookClientId
        params["scope"] = ServiceData.outlookOfflineScopes.joined(separator: " ")
        params["code"] = code
        params["redirect_uri"] = redirectUrl
        params["client_secret"] = ConfigureKeys.outlookSecretKey
        OutlookCommand().getMicrosoftLoginToken(params: params) { (result, error) in
            if let data = result, error == nil {
                callback(data, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
    
    func getMicrosoftUserInfo(_ token: String, callback: @escaping ([String: Any]?, Error?) -> ()) {
        OutlookCommand().getMicrosoftUserInfo(token: token) { (result, error) in
            if let data = result, error == nil {
                callback(data, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
    
    func getOutlookAssessTokenFromRefreshToken(_ socialUser: SocialUser, redirectUri url: String, callback: @escaping (SocialUser?, Error?) -> ()) {
        let expirationDate = Date()
        self.getAccessTokenFromRefreshToken(socialUser.refreshToken, redirectUrl: url) { (result, error) in
            if let data = result, error == nil, let token = data["access_token"] as? String, let refreshToken = data["refresh_token"] as? String, let expiresIn  = data["expires_in"] as? Int {
                socialUser.token = token
                socialUser.refreshToken = refreshToken
                socialUser.expiryTokenDate = expirationDate.adding(seconds: expiresIn).stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            else {
                socialUser.expiryTokenDate = Strings.empty
            }
            callback(socialUser, nil)
        }
    }
}

class OutlookCommand: SocialService {
    
    func calendar(url: String, client: MSHTTPClient, result: @escaping ([[String: Any]]?, String?, Error?) -> ()) {
        self.outlookService(url: url, client: client, completionHandler: { response, link, error in
            DispatchQueue.main.async {
                if let calenderEvents = response as?  [[String: Any]] {
                    result(calenderEvents, link, nil)
                }
                else {
                    result(nil, nil, error)
                }
            }
        })
    }
    
    func getMicrosoftLoginToken(params: [String: Any], result: @escaping ([String: Any]?, Error?) -> ()) {
        SocialService().outlookGetAccessRefreshToken(params: params) { (response, error) in
            if let data = response as?  [String: Any] {
                if (data["error"] as? String) != nil {
                    result(nil, nil)
                }
                else {
                   result(data, nil)
                }
            }
            else {
                result(nil, error)
            }
        }
    }
    
    func getMicrosoftUserInfo(token: String, result: @escaping ([String: Any]?, Error?) -> ()) {
        SocialService().outlookGetUserInfo(token: token) { (response, error) in
            if let data = response as?  [String: Any] {
                if (data["error"] as? String) != nil {
                    result(nil, nil)
                }
                else {
                   result(data, nil)
                }
            }
            else {
                result(nil, error)
            }
        }
    }
}

class OutlookAuthenticationManager: NSObject, MSAuthenticationProvider {
    
    let token: String
    
    init(with token: String) {
        self.token = token
    }
    
    func getAccessToken(for authProviderOptions: MSAuthenticationProviderOptions!, andCompletion completion: ((String?, Error?) -> Void)!) {
        completion(self.token, nil)
    }
}
