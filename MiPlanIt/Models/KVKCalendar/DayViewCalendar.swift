//
//  DayViewCalendar.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

final class DayViewCalendar: UIView {
    private var style: Style
    private var data: DayData
    private var daySelectionFromMonth: Bool = false
    weak var delegate: CalendarPrivateDelegate?
    
    lazy var scrollHeaderDay: ScrollDayHeaderView = {
        let heightView: CGFloat
        if style.headerScroll.isHiddenTitleDate {
            heightView = style.headerScroll.heightHeaderWeek
        } else {
            heightView = style.headerScroll.heightHeaderWeek + style.headerScroll.heightTitleDate
        }
        let view = ScrollDayHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: heightView),
                                       days: data.days,
                                       date: data.date,
                                       type: .day,
                                       style: style)
        view.delegate = self
        return view
    }()
    
    private lazy var timelineView: TimelineView = {
        var timelineFrame = frame
        timelineFrame.origin.y = scrollHeaderDay.frame.height
        timelineFrame.size.height -= scrollHeaderDay.frame.height
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isPortrait {
                timelineFrame.size.width = UIScreen.main.bounds.width * 0.5
            } else {
                timelineFrame.size.width -= style.timeline.widthEventViewer
            }
        }
        let view = TimelineView(type: .day, timeHourSystem: data.timeSystem, style: style, frame: timelineFrame, fromMonthDaySelection: self.daySelectionFromMonth)
        view.delegate = self
        return view
    }()
    
    private lazy var topBackgroundView: UIView = {
        let heightView: CGFloat
        if style.headerScroll.isHiddenTitleDate {
            heightView = style.headerScroll.heightHeaderWeek
        } else {
            heightView = style.headerScroll.heightHeaderWeek + style.headerScroll.heightTitleDate
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: heightView))
        view.backgroundColor = style.headerScroll.colorBackground
        return view
    }()
    
    init(data: DayData, frame: CGRect, style: Style, fromMonthDaySelection: Bool) {
        self.daySelectionFromMonth = fromMonthDaySelection
        self.style = style
        self.data = data
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEventView(view: UIView) {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        
        var eventFrame = timelineView.frame
        eventFrame.origin.x = eventFrame.width
        if UIDevice.current.orientation.isPortrait {
            eventFrame.size.width = UIScreen.main.bounds.width * 0.5
        } else {
            eventFrame.size.width = style.timeline.widthEventViewer
        }
        view.frame = eventFrame
        view.tag = -1
        addSubview(view)
        delegate?.getEventViewerFrame(eventFrame)
    }
    
    func setDate(_ date: Date) {
        data.date = date
        scrollHeaderDay.setDate(date)
    }
    
    func reloadData(events: [Event]) {
        data.events = events
        scrollHeaderDay.reloadData(daySelectionFromMonth: self.daySelectionFromMonth)
        timelineView.create(dates: [data.date], events: events.filter({ return compareStartEndDate(event: $0, date: data.date) }), selectedDate: data.date)
    }
}

extension DayViewCalendar: ScrollDayHeaderDelegate {
    func didSelectDateScrollHeader(_ date: Date?, type: CalendarType) {
        guard let selectDate = date else { return }
        data.date = selectDate
        delegate?.didSelectCalendarDate(selectDate, type: type, frame: nil)
    }
}

extension DayViewCalendar: TimelineDelegate {
    
    func setVisibilityEventIcon(with status: Bool) {
        self.delegate?.setVisibilityEventIcon(with: status)
    }
    
    func didTimeLineChangedFinished(to dateTime: Date, with events: [Event]) {
        self.delegate?.didFinihChangeTimeLine(dateTime, with: events)
    }
    
    func didTimeLineChanged(to dateTime: Date, with events: [Event], onDragging flag: Bool) {
        self.delegate?.didChangeTimeLine(dateTime, with: events, onDragging: flag)
    }
    
    func didDisplayEvents(_ events: [Event], dates: [Date?]) {
        delegate?.didDisplayCalendarEvents(events, dates: dates, type: .day)
    }
    
    func didSelectEvent(_ event: Event, frame: CGRect?) {
        delegate?.didSelectCalendarEvent(event, frame: frame)
    }
    
    func nextDate() {
        scrollHeaderDay.selectDate(offset: 1)
    }
    
    func previousDate() {
        scrollHeaderDay.selectDate(offset: -1)
    }
    
    func swipeX(transform: CGAffineTransform, stop: Bool) {
        
    }
    
    func didAddEvent(minute: Int, hour: Int, point: CGPoint) {
        var components = DateComponents()
        components.year = data.date.year
        components.month = data.date.month
        components.day = data.date.day
        components.hour = hour
        components.minute = minute
        let date = style.calendar.date(from: components)
        delegate?.didAddCalendarEvent(date)
    }
    
    func didChangeEvent(_ event: Event, minute: Int, hour: Int, point: CGPoint) {
        var startComponents = DateComponents()
        startComponents.year = event.start.year
        startComponents.month = event.start.month
        startComponents.day = event.start.day
        startComponents.hour = hour
        startComponents.minute = minute
        let startDate = style.calendar.date(from: startComponents)
        
        let hourOffset = event.end.hour - event.start.hour
        let minuteOffset = event.end.minute - event.start.minute
        var endComponents = DateComponents()
        endComponents.year = event.end.year
        endComponents.month = event.end.month
        endComponents.day = event.end.day
        endComponents.hour = hour + hourOffset
        endComponents.minute = minute + minuteOffset
        let endDate = style.calendar.date(from: endComponents)
                
        delegate?.didChangeCalendarEvent(event, start: startDate, end: endDate)
    }
}

extension DayViewCalendar: CalendarSettingProtocol, CompareEventDateProtocol {
    func reloadFrame(_ frame: CGRect) {
        self.frame = frame
        topBackgroundView.frame.size.width = frame.width
        scrollHeaderDay.reloadFrame(frame)
        
        var timelineFrame = timelineView.frame
        timelineFrame.size.height = frame.height - scrollHeaderDay.frame.height
        timelineFrame.size.width = frame.width
        timelineView.reloadFrame(timelineFrame)
        timelineView.create(dates: [data.date], events: data.events.filter({ return compareStartEndDate(event: $0, date: data.date) }), selectedDate: data.date)
    }
    
    func updateStyle(_ style: Style) {
        self.style = style
        scrollHeaderDay.updateStyle(style)
        timelineView.updateStyle(style)
        setUI()
        setDate(data.date)
    }
    
    func setUI() {
        subviews.forEach({ $0.removeFromSuperview() })
        
        addSubview(topBackgroundView)
        topBackgroundView.addSubview(scrollHeaderDay)
        addSubview(timelineView)
    }
}
