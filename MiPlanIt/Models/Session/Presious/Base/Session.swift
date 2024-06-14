//
//  Session.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import EventKit
import Contacts

class Session: NSObject, CompareEventDateProtocol {
    
    static let shared = Session()
    private var userId: String?
    private var user: PlanItUser?
    private var cache: [String] = []
    private var isSyncingStarted = false//Offline support
    private var isUsersShareLinkDataFetching = false//Users data unwanted calls
    private var isUsersTodoDataFetching = false//Users data unwanted calls
    private var isUsersGiftDataFetching = false//Users data unwanted calls
    private var isUsersCalendarDataFetching = false//Users data unwanted calls
    private var isUsersCalendarOnlyDataFetching = false//Users data unwanted calls
    private var isUsersShoppingDataFetching = false//Users data unwanted calls
    private var isUsersPurchaseDataFetching = false//Users data unwanted calls
    private var isNeedToShowAnimation = true//Splash Animation
    private var isSocialDataSyncedToServer = false//Import
    private var isAppFromForeGround = false//Server social account refresh
    private var fastestEvents: [Event] = []
    private var fastestCalendars: [MiPlanItEventCalendar] = []
    private var isOthersCalendarAccessed = false//MyCalendar
    var fastestEventStatus = FastestEventStatus.default
    var offlineTimer: Timer?
    var pushNotificationPayload: AnyObject?
    var allContactUser: [CalendarUser] = []
    var allDatabaseUser: [CalendarUser] = []
    var isAllContactUserFetching = false//is fetching user contact
    var isAllDatabaseUserFetching = false//is fetching user DB
    var versionAlertShowing = false //is Version Alert Showing
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var hiddenEventFlagFromNotification: Bool = false
    var eachTypesSectionCount: [Date: [DashBoardTitle: [DashBoardSection: Int]]] = [:]
    var lastShownInterstitialAds: Date?
    var initialPricingVCShown: Bool = true//false

    lazy var eventStore: EKEventStore = {
        return EKEventStore()
    }()
    
    lazy var colors: [ColorCode] = {
        guard let path = Bundle.main.path(forResource: "ColorCodes", ofType: "plist") else { return [] }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [[String: Any]] else { return [] }
        return plist.map({ return ColorCode($0) })
    }()
    
    lazy var textColors: [String: String] = {
        guard let path = Bundle.main.path(forResource: "TextColorCodes", ofType: "plist") else { return [:] }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else { return [:] }
        return plist
    }()
    
    lazy var dashboardCards: [DashboardCard] = {
        guard let path = Bundle.main.path(forResource: "DashboardCard", ofType: "plist") else { return [] }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [[String: Any]] else { return [] }
        return plist.map({ return DashboardCard($0) })
    }()
    
    lazy var knownTimeZones: [TimeZone] = {
        return TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
    }()
    
    //MARK: - Save
    func saveUser(_ user: PlanItUser?) {
        self.user = user
        self.userId = user?.readValueOfUserId()
        self.startToReadUserBasicInformation()
    }
    
    func saveAnimationShowStatus(_ status: Bool) {
        self.isNeedToShowAnimation = status
    }
    
    func saveSocialCalendarFetchStatus(_ status: Bool) {
        self.isSocialDataSyncedToServer = status
    }
    
    func saveOthersCalendarAccessed(_ status: Bool) {
        self.isOthersCalendarAccessed = status
    }
    
    func saveSyncingStarted(_ status: Bool) {
        self.isSyncingStarted = status
    }
    
    func saveUsersCalendarDataFetching(_ status: Bool) {
        self.isUsersCalendarDataFetching = status
    }
    
    func saveUsersCalendarOnlyDataFetching(_ status: Bool) {
        self.isUsersCalendarOnlyDataFetching = status
    }
    
    func saveUsersShareLinkDataFetching(_ status: Bool) {
        self.isUsersShareLinkDataFetching = status
    }
    
    func saveUsersTodoDataFetching(_ status: Bool) {
        self.isUsersTodoDataFetching = status
    }
    
    func saveUsersShoppingDataFetching(_ status: Bool) {
        self.isUsersShoppingDataFetching = status
    }
    
    func saveUsersGiftDataFetching(_ status: Bool) {
        self.isUsersGiftDataFetching = status
    }
    
    func saveUsersPurchaseDataFetching(_ status: Bool) {
        self.isUsersPurchaseDataFetching = status
    }
    
    func saveFastestEvents(_ events: [Event]) {
        self.fastestEvents = events
    }
    
    func saveFastestCalendars(_ calendars: [MiPlanItEventCalendar]) {
        self.fastestCalendars = calendars
    }

    func saveAppFromForeGround(_ status: Bool) {
        self.isAppFromForeGround = status
    }
    
    func saveToCache(_ path: String) {
        self.cache.append(path)
    }
    
    func saveEachTypesSectionCount(_ section: DashBoardSection, count: Int, type: DashBoardTitle) {
        let initialDate = Date().initialHour()
        if let item = self.eachTypesSectionCount[initialDate] {
            if item[type] != nil {
                self.eachTypesSectionCount[initialDate]?[type]?[section] = count
            }
            else {
                let dashboardSection = [section: count]
                self.eachTypesSectionCount[initialDate]?[type] = dashboardSection
            }
        }
        else {
            self.eachTypesSectionCount.removeAll()
            let dashboardSection = [section: count]
            let typeData = [type : dashboardSection]
            self.eachTypesSectionCount[initialDate] = typeData
        }
    }
    
    func saveLastShownInterstitialAds() {
        self.lastShownInterstitialAds = Date()
    }

    //MARK: - Read
    func readUser() -> PlanItUser? {
        return self.user
    }
    
    func readUserId() -> String {
        return self.userId ?? Strings.empty
    }
    
    func readAnimationShowStatus() -> Bool {
        return self.isNeedToShowAnimation
    }
    
    func readSocialCalendarFetchStatus() -> Bool {
        return self.isSocialDataSyncedToServer
    }
    
    func readSyncingStarted() -> Bool {
        return self.isSyncingStarted
    }
    
    func readUsersCalendarDataFetching() -> Bool {
        return self.isUsersCalendarDataFetching
    }
    
    func readUsersCalendarOnlyDataFetching() -> Bool {
        return self.isUsersCalendarOnlyDataFetching
    }
    
    func readUsersShareLinkDataFetching() -> Bool {
        return self.isUsersShareLinkDataFetching
    }
    
    func readUsersTodoDataFetching() -> Bool {
        return self.isUsersTodoDataFetching
    }
    
    func readUsersShoppingDataFetching() -> Bool {
        return self.isUsersShoppingDataFetching
    }
    
    func readUsersGiftDataFetching() -> Bool {
        return self.isUsersGiftDataFetching
    }
    
    func readUsersPurchaseDataFetching() -> Bool {
        return self.isUsersPurchaseDataFetching
    }
    
    func readDeviceId() -> String {
        if let deviceId = Storage().readString(UserDefault.deviceId), !deviceId.isEmpty {
            return deviceId
        }
        else {
            let deviceId = UUID().uuidString
            Storage().saveString(object: deviceId, forkey: UserDefault.deviceId)
            return deviceId
        }
    }
    
    func readDeviceToken() -> String {
        if let deviceToken = Storage().readString(UserDefault.deviceToken) {
            return deviceToken
        }
        return Strings.empty
    }
    
    func readOthersCalendarAccessed () -> Bool {
        return self.isOthersCalendarAccessed
    }
    
    func readFastestEvents() -> [Event] {
        return self.fastestEvents
    }
    
    func readFastestCalendars() -> [MiPlanItEventCalendar] {
        return self.fastestCalendars
    }
    
    func readAppFromForeGround() -> Bool {
        return self.isAppFromForeGround
    }
    
    func readCache() -> [String] {
        return self.cache
    }
    
    func readIsExhausted() -> Bool {
        return self.user?.readIsExhausted() ?? false
    }
    
    func readLastShownInterstitialAds() -> Date? {
        return self.lastShownInterstitialAds
    }
    
    func readEachTypesSectionCount(section: DashBoardSection, type: DashBoardTitle) -> Int? {
        return self.eachTypesSectionCount[Date().initialHour()]?[type]?[section]
    }
    
    func readInitialPricingPopUpShown() -> Bool {
        return self.initialPricingVCShown
    }
    
    func updateInitialPricingPopUp(with flag: Bool) {
        self.initialPricingVCShown = flag
    }
    
    func clearEachTypesSectionCount() {
        self.eachTypesSectionCount.removeAll()
    }
    
    func removeEventFromFastestEventOfCalendar(_ calendarId: String) {
        self.fastestEvents.removeAll { (event) -> Bool in
            event.calendarId == calendarId
        }
    }
    
    func startToReadUserBasicInformation() {
        self.readAllUserContacts()
        self.loadFastestCalendars()
        self.loadFastestEvents()
        self.startOfflineSyncingTimer()
        self.refreshAppleCalendarsEvents()
        self.registerUserLocationNotification()
        SocialManager.default.startSocialTokenRefreshTimer()
        NotificationService().registerNotificationForUser()
        UserService().checkUserStorageExhausted()
        UIApplication.shared.applicationIconBadgeNumber = Int(self.user?.readValueOfNotificationCount() ?? 0.0)
    }
    
    func startOnlineDataProcessing() {
        self.refreshAppleCalendarsEvents()
    }
    
    func updateEventIfAnyHiddenEvents() {
        guard self.readUser() != nil && self.hiddenEventFlagFromNotification else { return }
        self.hiddenEventFlagFromNotification = false
        self.createServiceToFetchUsersEventData()
    }
    
    func timeToShowInterstitialAds() -> Bool {
        guard let lastDate = self.lastShownInterstitialAds else { return true }
        return Date().secondDiffrence(from: lastDate) >= ConfigureKeys.adIntersticialTimeIntervalInSeconds
    }
    
    //MARK: - clear
    func clearUser() {
        self.hiddenEventFlagFromNotification = false
        self.isNeedToShowAnimation = false
        self.user?.saveLoggedInStatus(false)
        self.user = nil
        self.userId = nil
        self.fastestEventStatus = .default
        self.fastestEvents.removeAll()
        self.fastestCalendars.removeAll()
        self.isSyncingStarted = false
        self.isUsersTodoDataFetching = false
        self.isUsersGiftDataFetching = false
        self.isUsersCalendarDataFetching = false
        self.isUsersShoppingDataFetching = false
        self.isUsersPurchaseDataFetching = false
        self.isOthersCalendarAccessed = false
        self.isSocialDataSyncedToServer = false
        self.lastShownInterstitialAds = nil
        self.isAppFromForeGround = false
        self.stopOfflineSyncingTimer()
        SocialManager.default.stopSocialTokenRefreshTimer()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.clearEachTypesSectionCount()
        self.initialPricingVCShown = true//false
    }
}
