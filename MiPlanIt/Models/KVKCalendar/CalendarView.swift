//
//  CalendarView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

public final class CalendarView: UIView, CompareEventDateProtocol {
    public weak var delegate: CalendarDelegate?
    public weak var dataSource: CalendarDataSource?
    private var daySelectionFromMonth: Bool = false
    private var calendarLayoutFrame: CGRect?
    var refreshControl = UIRefreshControl()
    public var selectedType: CalendarType {
        return type
    }
    
    private lazy var style: Style = {
        return Style()
    }()
    
    private lazy var type: CalendarType = {
        return .day
    }()
    
    private lazy var yearData: YearData = {
        return YearData(date: Date(), years: 4, style: Style())
    }()
    
    private lazy var weekData: WeekData = {
        return WeekData(yearData: self.yearData, timeSystem: Style().timeHourSystem, startDay: Style().startWeekDay)
    }()
    
    private lazy var monthData: MonthData = {
        return MonthData(yearData: self.yearData, startDay: Style().startWeekDay)
    }()
    
    private lazy var dayData: DayData = {
        return DayData(yearData: self.yearData, timeSystem: Style().timeHourSystem, startDay: Style().startWeekDay)
    }()
    
    private var events: [Event] {
        return dataSource?.eventsForCalendar() ?? []
    }
    
    private lazy var dayCalendar: DayViewCalendar = {
        let day = DayViewCalendar(data: self.dayData, frame: frame, style: style, fromMonthDaySelection: self.daySelectionFromMonth)
        day.delegate = self
        day.scrollHeaderDay.dataSource = self
        return day
    }()
    
    private lazy var weekCalendar: WeekViewCalendar = {
        let week = WeekViewCalendar(data: self.weekData, frame: frame, style: style)
        week.delegate = self
        week.scrollHeaderDay.dataSource = self
        return week
    }()
    
    private lazy var monthCalendar: MonthViewCalendar = {
        let month = MonthViewCalendar(data: self.monthData, frame: frame, style: style)
        month.delegate = self
        month.dataSource = self
        return month
    }()
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.frame = frame
        v.backgroundColor = .clear
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        addSubview(scrollView)
        self.setRefreshController()
    }
    
    func setRefreshController() {
        self.refreshControl = self.scrollView.addRefreshControl(target: self,
                                                          action: #selector(doRefresh(_:)))
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
    }
    
    @objc func doRefresh(_ sender: UIRefreshControl) {
        self.delegate?.refereshCalendarData()
        self.refreshControl.endRefreshing()
    }

    private func switchTypeCalendar(type: CalendarType) {
        self.type = type
        if UIDevice.current.userInterfaceIdiom == .phone && type == .year {
            self.type = .month
        }
//        subviews.filter({ $0 is DayViewCalendar
//            || $0 is WeekViewCalendar
//            || $0 is MonthViewCalendar}).forEach({ $0.removeFromSuperview() })
        
        self.scrollView.subviews.filter({ $0 is DayViewCalendar
            || $0 is WeekViewCalendar
            || $0 is MonthViewCalendar}).forEach({ $0.removeFromSuperview() })
        
        
        switch self.type {
        case .day:
            self.scrollView.addSubview(dayCalendar)
        case .week:
            self.scrollView.addSubview(weekCalendar)
        case .month:
            self.scrollView.addSubview(monthCalendar)
        default:
            self.scrollView.addSubview(dayCalendar)
        }
    }
    
    public func addEventViewToDay(view: UIView) {
        dayCalendar.addEventView(view: view)
    }
    
    public func set(type: CalendarType, date: Date, fromMonthDaySelection: Bool = false) {
        self.type = type
        self.daySelectionFromMonth = fromMonthDaySelection
        switchTypeCalendar(type: type)
        scrollTo(date)
    }
    
    public func reloadData() {
        switch type {
        case .day:
            dayCalendar.reloadData(events: events)
        case .week:
            weekCalendar.reloadData(events: events)
        case .month:
            monthCalendar.reloadData(events: events)
        case .year:
            break
        }
    }
    
    @available(*, deprecated, renamed: "scrollTo")
    public func scrollToDate(date: Date) {
        switch type {
        case .day:
            dayCalendar.setDate(date)
        case .week:
            weekCalendar.setDate(date)
        case .month:
            monthCalendar.setDate(date)
        default:
            dayCalendar.setDate(date)
        }
    }
    
    public func scrollTo(_ date: Date) {
        switch type {
        case .day:
            dayCalendar.setDate(date)
//            weekCalendar.setDate(date)
        case .week:
            weekCalendar.setDate(date)
        case .month:
            monthCalendar.setDate(date)
        default:
            dayCalendar.setDate(date)
        }
    }
}

extension CalendarView: DisplayDataSource {
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        return dataSource?.willDisplayDate(date, events: events)
    }
    
    func willExistEventOnDate(_ date: Date?) -> Bool {
        return self.events.contains(where: { return compareStartEndDate(event: $0, date: date) })
    }
}

extension CalendarView: CalendarPrivateDelegate {
    
    func setVisibilityEventIcon(with status: Bool) {
        self.delegate?.setVisibilityEventIcon(with: status)
    }
    
    func didFinihChangeTimeLine(_ date: Date?, with events: [Event]) {
        self.delegate?.didChangeTimeLine(date, with: events, onDragging: false)
    }
    
    func didChangeTimeLine(_ date: Date?, with events: [Event], onDragging flag: Bool) {
        self.delegate?.didChangeTimeLine(date, with: events, onDragging: flag)
    }
    
    func didDisplayCalendarEvents(_ events: [Event], dates: [Date?], type: CalendarType) {
        guard self.type == type else { return }
        
        delegate?.didDisplayEvents(events, dates: dates)
    }
    
    func didSelectCalendarDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
        delegate?.didSelectDate(date, type: type, frame: frame)
    }
    
    func didSelectCalendarEvent(_ event: Event, frame: CGRect?) {
        delegate?.didSelectEvent(event, type: type, frame: frame)
    }
    
    func didSelectCalendarMore(_ date: Date, frame: CGRect?) {
        delegate?.didSelectMore(date, frame: frame)
    }
    
    func didAddCalendarEvent(_ date: Date?) {
        delegate?.didAddEvent(date, type: type)
    }
    
    func didChangeCalendarEvent(_ event: Event, start: Date?, end: Date?) {
        delegate?.didChangeEvent(event, start: start, end: end)
    }
    
    func calendarEventViewerFrame(_ frame: CGRect) {
        var newFrame = frame
        newFrame.origin = .zero
        delegate?.eventViewerFrame(newFrame)
    }
}

extension CalendarView: CalendarSettingProtocol {
    public func reloadFrame(_ frame: CGRect) {
        self.frame = frame
        if let calendarLayoutFrame = self.calendarLayoutFrame, calendarLayoutFrame.width == frame.width, calendarLayoutFrame.height == frame.height {
            return
        }
        self.scrollView.frame = frame
        self.calendarLayoutFrame = frame
        switch type {
        case .day:
            dayCalendar.reloadFrame(frame)
        case .week:
            weekCalendar.reloadFrame(frame)
        case .month:
            monthCalendar.reloadFrame(frame)
        default:
            dayCalendar.reloadFrame(frame)
        }
    }
    
    public func setStyle(_ style: Style) {
        self.style = style
    }
    
    // TODO: in progress
    public func updateStyle(_ style: Style) {
        self.style = style
        switch type {
        case .day:
            dayCalendar.updateStyle(style)
        case .week:
            weekCalendar.updateStyle(style)
        case .month:
            monthCalendar.updateStyle(style)
        default:
            dayCalendar.updateStyle(style)
        }
    }
}
