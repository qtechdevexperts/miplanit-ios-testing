//
//  MyCalanderBaseViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 31/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol refresh{
    func calendarRefresh()
}

class MyCalanderBaseViewController: BaseViewController {

    @IBOutlet weak var viewForAlpha: UIView!
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var buttonDrawer: UIButton!
    @IBOutlet weak var viewCalanderHolder: UIView!
    @IBOutlet weak var viewCalendarList: UsersListView!
    @IBOutlet weak var viewCalendarListContainer: UIView!
    @IBOutlet weak var viewUsersMainList: UsersListView!
    @IBOutlet weak var labelOtherUsersCount: UILabel!
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var centerXConstraints: NSLayoutConstraint!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var buttonExpandMenu: UIButton!
    @IBOutlet weak var constraintTabHeight: NSLayoutConstraint?
    
    var events = [Event]()
    var allEvents = [Event]()
    var pendingNewEvents: [Double] = []
    var isNewEventSynchronisationStarted = false
    var isForwardSynchronisationStarted = false
    var isBackwardSynchronisationStarted = false
    var isForwardOtherSynchronisationStarted = false
    var isForwardReSynchronisationNeeded = false
    var isBackwardReSynchronisationNeeded = false
    var isForwardOtherReSynchronisationNeeded = false
    var isForceFullyStoppedBackgroundProcess = false
    var forwardCounter = Counters.forwardEvent.rawValue
    var backwardCounter = Counters.backwardEvent.rawValue
    var calendarType: MiPlanItCalendarType = .myCalendar
//    var helloWorldTimer = Timer.scheduledTimer(timeInterval: 10.0, target: MyCalanderBaseViewController.self, selector: #selector(MyCalanderBaseViewController.sayHello), userInfo: nil, repeats: true)
    weak var timer: Timer?
    var timerNew = Timer()

    
    
    //////
    var showingDisabledCalendars: [UserCalendarVisibility] = []
    var selectedCalendars: [PlanItCalendar] = []
    var deletedCalendars: [PlanItCalendar] = []
    var updatedCalendars: [PlanItCalendar] = []
    var allDisabledCalendars: [UserCalendarVisibility] = [] {
        didSet {
            self.showingDisabledCalendars = self.allDisabledCalendars
        }
    }
    ///////
    lazy var isImportHappened: Bool = {
        return Session.shared.readSocialCalendarFetchStatus()
    }()

    var collectedMaxMonth = Date().startOfMonth {
        didSet {
            self.refreshCalendarIfNeeded()
        }
    }
    var collectedOthersMaxMonth = Date().startOfMonth {
        didSet {
            self.refreshCalendarIfNeeded()
        }
    }
    var collectedMinMonth = Date().addMonth(n: -1).startOfMonth {
        didSet {
            self.refreshCalendarIfNeeded()
        }
    }
    
    var selectedDate: Date = Date().initialHour() {
        didSet {
            self.selectedMonth = self.selectedDate.startOfTheMonth()
        }
    }
    
    var selectedMonth: Date = Date().startOfTheMonth() {
        didSet {
            self.showEventLoadingIndicator()
            if self.selectedMonth != oldValue {
                self.refreshEvents()
            }
        }
    }
    
    var selectedCalanders: [PlanItCalendar] = [] {
        didSet {
            guard self.calendarType == .myCalendar else { return }
            self.manageUsersEventIntialValues()
            self.readEventsFromSelectedCalendar()
        }
    }
    
    var otherUsers: [OtherUser] = [] {
        didSet {
            if self.otherUsers.count > 0 {
                self.manageOthersEventIntialValues()
                self.readEventsOfOtherUsers()
            }
            else {
                self.labelOtherUsersCount.isHidden = true
            }
        }
    }
    
    lazy var allAvailableCalendars: [PlanItCalendar] = {
        return self.getAvailableCalendars()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.intialiseUIComponents()
        self.createServiceToFetchUsersData()
        self.addNotifications()
        self.timerNew = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.updateCounting()
        })
    }
    func updateCounting(){
        print("counting...")
        var test = self.readAllAvailableCalendars()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.manipulateUserEventsAsynchronously()
//        self.createServiceToFetchUsersData()
        self.addNotifications()
        calendarView.reloadData()
        super.viewWillAppear(animated)
        isCalendar = true
        var test = self.readAllAvailableCalendars()
        refereshCalendarData()
        self.createServiceToFetchUsersData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.forcefullyStopEventSynchronisation(true)
        if self.isBeingRemoved() {
            self.removeNotifications()
        }
        isCalendar = false
        super.viewWillDisappear(animated)
        timerNew.invalidate()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let vc = CalanderDropDownBaseListViewController()
//        vc.isCheck = testing
//        vc.test()
//        testing = false
        self.calendarView.layoutIfNeeded()
        let calendarFrame = CGRect(x: 0, y: 0, width: self.calendarView.frame.width, height: self.calendarView.frame.height)
        self.calendarView.reloadFrame(calendarFrame)
    }
    deinit {
        stopTimer()
    }

    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard let serviceDetection = notify.object as? [ServiceDetection] else { return }
        self.refreshCalendarScreenWithUpdates(serviceDetection)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.isHelpShown() {
            self.performSegue(withIdentifier: "toHelpScreen", sender: nil)
            Storage().saveBool(flag: true, forkey: UserDefault.calendarHelp)
        }
    }
     func sayHello(){
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            var get = self?.readAllAvailableCalendars()
        }
    }
    func stopTimer() {
        timer?.invalidate()
    }
    @IBAction func switchCalendar(_ sender: UISegmentedControl) {
        self.viewCalendarList.isHidden = sender.selectedSegmentIndex == 2
        let array = CalendarType.allCases.filter({ $0 != .year })
        let control = UISegmentedControl(items: array.map({ $0.rawValue.capitalized }))
        control.selectedSegmentIndex = 0
        let type = CalendarType.allCases[sender.selectedSegmentIndex]
        self.calendarView.set(type: type, date: self.selectedDate)
        self.calendarView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .calendar
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .myCalendar
            tabViewController.delegate = self
        case is AddCalendarViewController:
            let addCalendarViewController = segue.destination as! AddCalendarViewController
            addCalendarViewController.delegate = self
        case is CreateEventsViewController:
            let createEventsViewController = segue.destination as! CreateEventsViewController
            createEventsViewController.delegate = self
            createEventsViewController.selectedData = self.selectedDate
            createEventsViewController.selectedCalendar = self.readSelectedCalendar()
            if let selectedDateTime = sender as? Date {
                createEventsViewController.selectedDateTime = selectedDateTime
            }
        case is InviteesStatusViewController:
            let inviteesStatusViewController = segue.destination as! InviteesStatusViewController
            inviteesStatusViewController.invitees = self.otherUsers
        case is ViewEventViewController:
            let viewEventViewController = segue.destination as! ViewEventViewController
            viewEventViewController.delegate = self
            if let dateEvent = sender as? Event {
                viewEventViewController.eventPlanOtherObject = dateEvent.eventData
                viewEventViewController.dateEvent = DateSpecificEvent(with: dateEvent)
            }
        case is SingleDayCalendarViewController:
            let singleDayCalendarViewController = segue.destination as! SingleDayCalendarViewController
            singleDayCalendarViewController.delegate = self
            if let dateEvents = sender as? ([Event], Date) {
                singleDayCalendarViewController.events = dateEvents.0
                singleDayCalendarViewController.selectedDate = dateEvents.1
                singleDayCalendarViewController.calendarType = self.calendarType
                singleDayCalendarViewController.selectedCalanders = self.selectedCalanders
                if self.calendarType == .OtherUser {
                    singleDayCalendarViewController.eventUsers = self.otherUsers
                    singleDayCalendarViewController.containsMiPlanItCalendarWithOtherUser = (!self.otherUsers.isEmpty && !self.viewCalendarList.showCalendarColor)
                }
            }
        case is ExpandedMenuViewController:
            let expandedMenuViewController = segue.destination as! ExpandedMenuViewController
            expandedMenuViewController.delegate = self
            expandedMenuViewController.menuButtonFrame = buttonExpandMenu.frame
        case is UserCalendarListViewController:
            let userCalendarListViewController = segue.destination as! UserCalendarListViewController
            userCalendarListViewController.delegate = self
            userCalendarListViewController.selectedCalendars = self.selectedCalanders
            userCalendarListViewController.selectedUsers = self.otherUsers.map({return CalendarUser($0)})
        default: break
        }
    }
}

extension MyCalanderBaseViewController:refresh{
    func calendarRefresh() {
//        self.calendarView.reloadData()
//        createServiceToFetchUsersData()
    }
}
