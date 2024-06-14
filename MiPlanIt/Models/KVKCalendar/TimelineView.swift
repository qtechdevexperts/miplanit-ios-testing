//
//  TimelineView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

final class TimelineView: UIView, CompareEventDateProtocol {
    weak var delegate: TimelineDelegate?
    
    private let tagCurrentHourLine = -10
    private let tagEventPagePreview = -20
    private let tagVerticalLine = -30
    private let tagShadowView = -40
    private let tagBackgroundView = -50
    private var style: Style
    private let hours: [String]
    private let timeHourSystem: TimeHourSystem
    private var allEvents = [Event]()
    private var timer: Timer?
    private var eventPreview: EventPageView?
    private var dates = [Date?]()
    private var selectedDate: Date?
    private var isEnabledAutoScroll = true
    private let eventPreviewXOffset: CGFloat = 50
    private let eventPreviewYOffset: CGFloat = 60
    private let eventPreviewSize = CGSize(width: 100, height: 100)
    private let type: CalendarType
    private var movingDragView = false {
        didSet {
            if movingDragView == false {
                self.stopScrollTimer()
                self.setVisibilityEventIcon()
            }
        }
    }
    private var isTopEdge: Bool = false
    private var isBottomEdge: Bool = false
    private var autoScrollTimer: Timer?
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = style.timeline.shadowColumnColor
        view.alpha = style.timeline.shadowColumnAlpha
        view.tag = tagShadowView
        return view
    }()
    
    private lazy var currentTimeLabel: TimelineLabel = {
        let label = TimelineLabel()
        label.tag = tagCurrentHourLine
        label.textColor = style.timeline.currentLineHourColor
        label.textAlignment = .center
        label.font = style.timeline.currentLineHourFont
        label.adjustsFontSizeToFitWidth = true
        label.text = self.getTwelveHourFormattedDate(Date())
        label.valueHash = Date().minute.hashValue
        label.backgroundColor = .clear//.white
        return label
    }()
    
    private lazy var movingMinutesLabel: TimelineLabel = {
        let label = TimelineLabel()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = style.timeline.movingMinutesColor
        label.textAlignment = .right
        label.font = style.timeline.timeFont
        return label
    }()
    
    private lazy var currentLineView: UIView = {
        let view = UIView()
        view.tag = tagCurrentHourLine
        view.backgroundColor = style.timeline.currentLineHourColor
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .grayMT//.white
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var imageViewDrag: UIImageView = {
        let imageViewDrag = UIImageView(frame: CGRect(x: self.frame.width - 30, y: self.currentLineView.frame.minY - 15, width: 31, height: 30))
        imageViewDrag.image = #imageLiteral(resourceName: "dragHandle")
        imageViewDrag.contentMode = .right
        return imageViewDrag
    }()
    
    private lazy var viewDrag: UIView = {
        let view = UIView()
        view.backgroundColor = style.timeline.currentLineHourColor
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 10))
        view.backgroundColor = .clear//.white
        return view
    }()
    
    func getTwelveHourFormattedDate(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    init(type: CalendarType, timeHourSystem: TimeHourSystem, style: Style, frame: CGRect, fromMonthDaySelection: Bool = false) {
        self.type = type
        self.timeHourSystem = timeHourSystem
        self.hours = timeHourSystem.hours
        self.style = style
        super.init(frame: frame)
        self.addSubview(headerView)
        
        var scrollFrame = frame
        scrollFrame.origin.y = self.headerView.frame.maxY + 20//0
        scrollFrame.size.height -= self.headerView.frame.height//0
        scrollView.frame = scrollFrame
        addSubview(scrollView)
        if !fromMonthDaySelection {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(swipeEvent))
            addGestureRecognizer(panGesture)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addEvent))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopTimer()
    }
    
    @objc private func addEvent(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: scrollView)
        let time = calculateChangeTime(pointY: point.y - style.timeline.offsetEvent - 6)
        if let minute = time.minute, let hour = time.hour {
            delegate?.didAddEvent(minute: minute, hour: hour, point: point)
        }
    }
    
    @objc private func swipeEvent(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        let endGesure = abs(translation.x) > (frame.width / 3.5)
        let events = scrollView.subviews.filter({ $0 is EventPageView })
        var eventsAllDay: [UIView]
        
        if style.allDay.isPinned {
            eventsAllDay = subviews.filter({ $0 is AllDayEventView })
            eventsAllDay += subviews.filter({ $0 is AllDayTitleView })
        } else {
            eventsAllDay = scrollView.subviews.filter({ $0 is AllDayEventView })
            eventsAllDay += scrollView.subviews.filter({ $0 is AllDayTitleView })
        }
        
        let eventViews = events + eventsAllDay
        
        switch gesture.state {
        case .began, .changed:
            guard abs(velocity.y) < abs(velocity.x) else { break }
            guard endGesure else {
                delegate?.swipeX(transform: CGAffineTransform(translationX: translation.x, y: 0), stop: false)
                
                eventViews.forEach { (view) in
                    view.transform = CGAffineTransform(translationX: translation.x, y: 0)
                }
                break
            }
    
            gesture.state = .ended
        case .failed:
            delegate?.swipeX(transform: .identity, stop: false)
            identityViews(eventViews)
        case .cancelled, .ended:
            guard endGesure else {
                delegate?.swipeX(transform: .identity, stop: false)
                identityViews(eventViews)
                break
            }
            
            let previousDay = translation.x > 0
            let translationX = previousDay ? frame.width : -frame.width
            
            UIView.animate(withDuration: 0.2, animations: { [weak delegate = self.delegate] in
                delegate?.swipeX(transform: CGAffineTransform(translationX: translationX * 0.8, y: 0), stop: true)
                
                eventViews.forEach { (view) in
                    view.transform = CGAffineTransform(translationX: translationX, y: 0)
                }
            }) { [weak delegate = self.delegate] (_) in
                guard previousDay else {
                    delegate?.nextDate()
                    return
                }
                
                delegate?.previousDate()
            }
        case .possible:
            break
        @unknown default:
            fatalError()
        }
    }
    
    private func createTimesLabel(start: Int) -> [TimelineLabel] {
        var times = [TimelineLabel]()
        for (idx, hour) in hours.enumerated() where idx >= start {
            let yTime = (style.timeline.offsetTimeY + style.timeline.heightTime) * CGFloat(idx - start)
            
            let time = TimelineLabel(frame: CGRect(x: style.timeline.offsetTimeX,
                                                   y: yTime,
                                                   width: style.timeline.widthTime,
                                                   height: style.timeline.heightTime))
            time.font = style.timeline.timeFont
            time.textAlignment = .center
            time.textColor = style.timeline.timeColor
            time.text = hour
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let hourTmp = TimeHourSystem.twentyFourHour.hours[idx]
            time.valueHash = formatter.date(from: hourTmp)?.hour.hashValue
            time.tag = idx - start
            times.append(time)
        }
        return times
    }
    
    private func createLines(times: [TimelineLabel]) -> [UIView] {
        var lines = [UIView]()
        for (idx, time) in times.enumerated() {
            let xLine = time.frame.width + style.timeline.offsetTimeX + style.timeline.offsetLineLeft
            let lineFrame = CGRect(x: xLine,
                                   y: time.center.y,
                                   width: frame.width - xLine - 15,
                                   height: style.timeline.heightLine)
            let line = UIView(frame: lineFrame)
            line.backgroundColor  = #colorLiteral(red: 0.3647058824, green: 0.3529411765, blue: 0.4431372549, alpha: 1) // line color change
            line.tag = idx
            if idx + 1 < times.count {
              lines.append(self.createDottedLine(labelNow: time, labelNext: times[idx + 1], color: #colorLiteral(red: 0.3647058824, green: 0.3529411765, blue: 0.4431372549, alpha: 1)))
            }
            lines.append(line)
        }
        return lines
    }
    
    private func createVerticalLine(pointX: CGFloat) -> UIView {
        let frame = CGRect(x: pointX , y: 10, width: 1, height: (CGFloat(25) * (style.timeline.heightTime + style.timeline.offsetTimeY))-60)
        let line = UIView(frame: frame)
        line.tag = tagVerticalLine
        line.backgroundColor = #colorLiteral(red: 0.3647058824, green: 0.3529411765, blue: 0.4431372549, alpha: 1) // vertical line change
        line.isHidden = !style.week.showVerticalDayDivider
        return line
    }
    
    func createDottedLine(labelNow: TimelineLabel,labelNext: TimelineLabel, color: CGColor) -> UIView {
        
        let yPosition = labelNow.center.y + (labelNext.center.y - labelNow.center.y) / 2
        let view = UIView(frame: CGRect(x: labelNow.frame.maxX + 5, y: yPosition, width: frame.width - labelNow.frame.maxX - 20 , height: 1))
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = UIColor.white.cgColor //Dotted line color change
        caShapeLayer.lineWidth = 0.5
        caShapeLayer.lineDashPattern = [2,3]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: view.frame.size.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        view.layer.addSublayer(caShapeLayer)
        return view
    }
    
    private func createAlldayEvents(events: [Event], date: Date?, width: CGFloat, originX: CGFloat) {
        guard !events.isEmpty else { return }
        let pointY = style.allDay.isPinned ? 10 : -style.allDay.height
        let allDay = AllDayEventView(events: events,
                                     frame: CGRect(x: originX, y: pointY, width: width, height: style.allDay.height),
                                     style: style.allDay,
                                     date: date)
        allDay.delegate = self
        let titleView = AllDayTitleView(frame: CGRect(x: 0,
                                                      y: pointY,
                                                      width: style.timeline.widthTime + style.timeline.offsetTimeX + style.timeline.offsetLineLeft,
                                                      height: style.allDay.height),
                                        style: style.allDay)
        
        if subviews.filter({ $0 is AllDayTitleView }).isEmpty || scrollView.subviews.filter({ $0 is AllDayTitleView }).isEmpty {
            if style.allDay.isPinned {
                addSubview(titleView)
            } else {
                scrollView.addSubview(titleView)
            }
        }
        if style.allDay.isPinned {
            addSubview(allDay)
        } else {
            scrollView.addSubview(allDay)
        }
    }
    
    private func setOffsetScrollView() {
        var offsetY: CGFloat = 0
        if !subviews.filter({ $0 is AllDayTitleView }).isEmpty || !scrollView.subviews.filter({ $0 is AllDayTitleView }).isEmpty {
            offsetY = style.allDay.height
        }
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: 20, right: 0)
    }
    
    private func getTimelineLabel(hour: Int) -> TimelineLabel? {
        return scrollView.subviews .filter({ (view) -> Bool in
            guard let time = view as? TimelineLabel else { return false }
            return time.valueHash == hour.hashValue }).first as? TimelineLabel
    }
    
    private func stopTimer() {
        if timer?.isValid ?? true {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func stopScrollTimer() {
        if self.autoScrollTimer?.isValid ?? true {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
            self.isTopEdge = false
            self.isBottomEdge = false
        }
    }
    
    private func updateTimeLabelPosition(time: TimelineLabel) {
        let nextDate = Date()
        var pointY = time.frame.origin.y
        if !self.subviews.filter({ $0 is AllDayTitleView }).isEmpty, self.style.allDay.isPinned {
            pointY -= self.style.allDay.height
        }
        pointY = self.calculatePointYByMinute(nextDate.minute, time: time)
        self.currentTimeLabel.frame.origin.y = pointY - 7.5
        self.currentLineView.frame.origin.y = pointY
        self.currentTimeLabel.valueHash = nextDate.minute.hashValue
        if self.movingDragView == false {
            self.imageViewDrag.frame.origin.y = pointY - 15
            self.viewDrag.frame.origin.y = pointY
            
            let time = calculateChangeTime(pointY: pointY - 10)
            if let minute = time.minute, let hour = time.hour {
                isEnabledAutoScroll = false
                guard let date = self.selectedDate else { return }
                self.delegate?.didTimeLineChangedFinished(to: date.initialHour().adding(hour: hour).adding(minutes: minute), with: self.allEvents)
            }
            
        }
    }
    private func movingCurrentLineHour() {
        guard !(timer?.isValid ?? false) else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let nextDate = Date()
            guard self.currentTimeLabel.valueHash != nextDate.minute.hashValue else { return }
            guard let time = self.getTimelineLabel(hour: nextDate.hour) else { return }
            self.updateTimeLabelPosition(time: time)
            self.currentTimeLabel.text = self.getTwelveHourFormattedDate(nextDate)
//            if let timeNext = self.getTimelineLabel(hour: nextDate.hour + 1) {
//                timeNext.isHidden = self.currentTimeLabel.frame.intersects(timeNext.frame)
//            }
//            time.isHidden = time.frame.intersects(self.currentTimeLabel.frame)
        }
        
        guard let timer = timer else { return }
        RunLoop.current.add(timer, forMode: .default)
    }
    
    private func autoScrollAnimationTimer() {
        guard !(autoScrollTimer?.isValid ?? false) else { return }
        self.autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.movingDragView {
                if self.isTopEdge {
                    if self.scrollView.contentOffset.y < -30 {
                        self.stopScrollTimer()
                        return
                    }
                    self.scrollView.contentOffset.y = self.scrollView.contentOffset.y - 1
                    self.viewDrag.center = CGPoint(x: self.viewDrag.center.x, y: self.viewDrag.center.y - 1)
                    self.imageViewDrag.center = CGPoint(x: self.self.imageViewDrag.center.x, y: self.imageViewDrag.center.y - 1)
                }
                if self.isBottomEdge {
                    if self.scrollView.contentOffset.y > (self.scrollView.contentSize.height - self.scrollView.frame.height) + 30 {
                        self.stopScrollTimer()
                        return
                    }
                    self.scrollView.contentOffset.y = self.scrollView.contentOffset.y + 1
                    self.viewDrag.center = CGPoint(x: self.viewDrag.center.x, y: self.viewDrag.center.y + 1)
                    self.imageViewDrag.center = CGPoint(x: self.imageViewDrag.center.x, y: self.imageViewDrag.center.y + 1)
                }
            }
            else {
                self.stopScrollTimer()
            }
        }
        guard let timer = self.autoScrollTimer else { return }
        RunLoop.current.add(timer, forMode: .default)
    }
    
    private func showCurrentLineHour() {
        let date = Date()
        guard style.timeline.showCurrentLineHour, let time = getTimelineLabel(hour: date.hour) else {
            currentLineView.removeFromSuperview()
            currentTimeLabel.removeFromSuperview()
            timer?.invalidate()
            return
        }
        
        var pointY = time.frame.origin.y
        if !subviews.filter({ $0 is AllDayTitleView }).isEmpty, style.allDay.isPinned {
            pointY -= style.allDay.height
        }
        
        pointY = calculatePointYByMinute(date.minute, time: time)
        
        currentTimeLabel.frame = CGRect(x: style.timeline.offsetTimeX,
                                        y: pointY - 8,
                                        width: style.timeline.currentLineHourWidth,
                                        height: 15)
        currentLineView.frame = CGRect(x: currentTimeLabel.frame.width + style.timeline.offsetTimeX + style.timeline.offsetLineLeft,
                                       y: pointY,
                                       width: scrollView.frame.width - style.timeline.offsetTimeX,
                                       height: 1)
        self.viewDrag.frame = CGRect(x: currentTimeLabel.frame.width + style.timeline.offsetTimeX + style.timeline.offsetLineLeft,
        y: pointY,
        width: scrollView.frame.width - style.timeline.offsetTimeX,
        height: 1)
        
        imageViewDrag.frame.origin.y = self.currentLineView.frame.minY - 15
        scrollView.addSubview(currentTimeLabel)
        scrollView.addSubview(currentLineView)
        scrollView.addSubview(imageViewDrag)
        scrollView.addSubview(viewDrag)
        
        let panGestureForCurrentTimeLine = UIPanGestureRecognizer(target: self, action: #selector(self.startDraggingCurrentTimeLine(_:)))
        self.imageViewDrag.addGestureRecognizer(panGestureForCurrentTimeLine)
        self.imageViewDrag.isUserInteractionEnabled = true
        movingCurrentLineHour()
        
//        if let timeNext = getTimelineLabel(hour: date.hour + 1) {
//            timeNext.isHidden = currentTimeLabel.frame.intersects(timeNext.frame)
//        }
//        time.isHidden = currentTimeLabel.frame.intersects(time.frame)
        if !self.allEvents.isEmpty, let selectedDate = self.selectedDate?.adding(hour: date.hour).adding(minutes: date.minute) {
            self.delegate?.didTimeLineChanged(to: selectedDate, with: self.allEvents, onDragging: self.movingDragView)
        }
    }
    
    private func calculatePointYByMinute(_ minute: Int, time: TimelineLabel) -> CGFloat {
        let pointY: CGFloat
        if 1...59 ~= minute {
            let minutePercent = 60.0 / CGFloat(minute)
            let newY = (style.timeline.offsetTimeY + time.frame.height) / minutePercent
            let summY = (CGFloat(time.tag) * (style.timeline.offsetTimeY + time.frame.height)) + (time.frame.height / 2)
            if time.tag == 0 {
                pointY = newY + (time.frame.height / 2)
            } else {
                pointY = summY + newY
            }
        } else {
            pointY = (CGFloat(time.tag) * (style.timeline.offsetTimeY + time.frame.height)) + (time.frame.height / 2)
        }
        return pointY
    }
    
    private func identityViews(duration: TimeInterval = 0.4, delay: TimeInterval = 0.07, _ views: [UIView], action: @escaping (() -> Void) = {}) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
            views.forEach { (view) in
                view.transform = .identity
            }
            action()
        }, completion: nil)
    }
    
    private func scrollToCurrentTime(startHour: Int) {
        guard isEnabledAutoScroll else {
            isEnabledAutoScroll = true
            return
        }
        
        guard let time = getTimelineLabel(hour: Date().hour), style.timeline.scrollToCurrentHour else {
            scrollView.setContentOffset(.zero, animated: true)
            return
        }
        if time.frame.origin.y > scrollView.contentSize.height - scrollView.frame.size.height {
            var offset = scrollView.contentOffset
            offset.y = scrollView.contentSize.height - scrollView.frame.size.height
            scrollView.setContentOffset(offset, animated: true)
        }
        else {
            var frame = scrollView.frame
            frame.origin.y = time.frame.origin.y - 30
            scrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    
    private func fillBackgroundDayColor(_ color: UIColor, pointX: CGFloat, width: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: pointX, y: 0.0, width: width, height: (CGFloat(25) * (style.timeline.heightTime + style.timeline.offsetTimeY)) - 75))
        view.backgroundColor = color
        view.tag = tagBackgroundView
        return view
    }
    private func getTimeWithouteSeconds(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }
    private func calculateCrossEvents(_ events: [Event]) -> [String: CrossEvent] {
        var eventsTemp = events
        var crossEvents = [String: CrossEvent]()
        
        while let event = eventsTemp.first {
            let start = self.getTimeWithouteSeconds(event.start)
            let end = self.getTimeWithouteSeconds(event.end)
            var crossEventNew = CrossEvent(eventTime: EventTime(start: start, end: end), eventId: event.id)
            
            var endCalculated: TimeInterval = crossEventNew.eventTime.end - TimeInterval(style.timeline.offsetEvent)
            endCalculated = crossEventNew.eventTime.start > endCalculated ? crossEventNew.eventTime.start : endCalculated
            let eventsFiltered = events.filter({ (item) in
                var itemEnd = self.getTimeWithouteSeconds(item.end) - TimeInterval(style.timeline.offsetEvent)
                let itemStart = self.getTimeWithouteSeconds(item.start)
                itemEnd = itemEnd < itemStart ? itemStart : itemEnd
                return (itemStart...itemEnd).contains(start) || (itemStart...itemEnd).contains(endCalculated) || (start...endCalculated).contains(itemStart) || (start...endCalculated).contains(itemEnd)
            })
            if !eventsFiltered.isEmpty {
                crossEventNew.count = eventsFiltered.count
            }
            crossEvents[crossEventNew.eventId] = crossEventNew
            eventsTemp.removeFirst()
        }
        
        return crossEvents
    }
    
    func create(dates: [Date?], events: [Event], selectedDate: Date?) {
        delegate?.didDisplayEvents(events, dates: dates)
        self.dates = dates
        self.allEvents = events
        self.selectedDate = selectedDate
        
        subviews.filter({ $0 is AllDayEventView || $0 is AllDayTitleView }).forEach({ $0.removeFromSuperview() })
        scrollView.subviews.filter({ $0.tag != tagCurrentHourLine }).forEach({ $0.removeFromSuperview() })

        let start = 0
        
        // add time label to timline
        let times = createTimesLabel(start: start)
        // add seporator line
        let lines = createLines(times: times)
        
        // calculate all height by time label
        let heightAllTimes = times.reduce(0, { $0 + ($1.frame.height + style.timeline.offsetTimeY) })
        scrollView.contentSize = CGSize(width: frame.width, height: heightAllTimes + 20)
        times.forEach({ scrollView.addSubview($0) })
        lines.forEach({ scrollView.addSubview($0) })

        let offset = style.timeline.widthTime + style.timeline.offsetTimeX + style.timeline.offsetLineLeft
        let widthPage = (frame.width - 15 - offset) / CGFloat(dates.count)
        let heightPage = (CGFloat(times.count) * (style.timeline.heightTime + style.timeline.offsetTimeY)) - 75
         let midnight = 24
        // horror
        for (idx, date) in dates.enumerated() {
            var pointX: CGFloat
            if idx == 0 {
                pointX = offset
            } else {
                pointX = CGFloat(idx) * widthPage + offset
            }
            scrollView.addSubview(createVerticalLine(pointX: pointX))
            
            if idx != 0 && idx == dates.count - 1 {
                scrollView.addSubview(createVerticalLine(pointX: (CGFloat(idx + 1) * widthPage + offset) - 2))
            }
            
            let eventsByDate = events
                .filter({ compareNormalDayStartEndDate(event: $0, date: date) })
                .sorted(by: { $0.start < $1.start })
            let sortedEventsByDate =
                eventsByDate.sorted(by: {
                                        if $0.start == $1.start {
                                            return $0.end > $1.end
                                        }
                                        else if $0.end > $1.end && $0.start < $1.end {
                                            return true
                                        }
                                        else {
                                            return $0.start < $1.start
                                        }
                })
            
            let allDayEvents = events.filter({ compareAllDayStartEndDate(event: $0, date: date) })
            createAlldayEvents(events: allDayEvents, date: date, width: widthPage, originX: pointX)
            // count event cross in one hour
            let crossEvents = calculateCrossEvents(sortedEventsByDate)
            var pagesCached = [EventPageView]()
            if !sortedEventsByDate.isEmpty {
                // create event
                var newFrame = CGRect(x: 0, y: 0, width: 0, height: heightPage)
                sortedEventsByDate.forEach { (event) in
                    var isStarted = false; var isEnded = false
                    times.forEach({ time in
                        // calculate position 'y'
                        let startHour = event.start.day == date?.day ? event.start : event.initialDate
                        if startHour.hour.hashValue == time.valueHash && !isStarted {
                            isStarted = true
                            if time.tag == midnight, let newTime = times.first(where: { $0.tag == 0 }) {
                                newFrame.origin.y = calculatePointYByMinute(startHour.minute, time: newTime)
                            } else {
                                newFrame.origin.y = calculatePointYByMinute(startHour.minute, time: time)
                            }
                        }
                        else if let firstTimeLabel = getTimelineLabel(hour: start), startHour.day != date?.day {
                            newFrame.origin.y = calculatePointYByMinute(start, time: firstTimeLabel)
                        }
                        // calculate 'height' event
                        let endHour = event.end.day == date?.day ? event.end : event.start.endOfDay ?? event.end
                        if endHour.hour.hashValue == time.valueHash && isStarted && !isEnded, endHour.day == date?.day {
                            var timeTemp = time
                            if time.tag == midnight, let newTime = times.first(where: { $0.tag == 0 }) {
                                timeTemp = newTime
                            }
                            isEnded = true
                            let summHeight = (CGFloat(timeTemp.tag) * (style.timeline.offsetTimeY + timeTemp.frame.height)) - newFrame.origin.y + (timeTemp.frame.height / 2)
                            if 0...59 ~= endHour.minute {
                                let minutePercent = 59.0 / CGFloat(endHour.minute)
                                let newY = (style.timeline.offsetTimeY + timeTemp.frame.height) / minutePercent
                                newFrame.size.height = summHeight + newY - style.timeline.offsetEvent
                            } else {
                                newFrame.size.height = summHeight - style.timeline.offsetEvent
                            }
                        }
                        else if endHour.day != date?.day {
                            newFrame.size.height = (CGFloat(time.tag) * (style.timeline.offsetTimeY + time.frame.height)) - newFrame.origin.y + (time.frame.height / 2)
                        }
                    })
                    
                    // calculate 'width' and position 'x'
                    var newWidth = widthPage
                    var newPointX = pointX
                    
                    
                    if let crossEvent = crossEvents[event.id] {
                        newWidth /= CGFloat(crossEvent.count)
                        newWidth -= style.timeline.offsetEvent
                        newFrame.size.width = newWidth
                        if crossEvent.count > 1, !pagesCached.isEmpty {
//                            for _ in 0..<crossEvent.count {
                                for page in pagesCached {
                                    let actualFrame = CGRect(origin: page.frame.origin, size: CGSize(width: page.frame.size.width, height: page.frame.size.height ))
                                    if actualFrame.intersects(CGRect(x: newPointX, y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height + style.timeline.offsetEvent)) {
                                        newPointX = page.frame.maxX > newPointX ? (page.frame.maxX + style.timeline.offsetEvent).rounded() : newPointX
                                    }
                                }
//                            }
                        }
                    }
                    
                    newFrame.origin.x = newPointX
                    let extraWidth = newFrame.maxX - pointX - widthPage
                    newFrame.size.width -= extraWidth > 0 ?  extraWidth : 0
                    let page = EventPageView(event: event, style: style, frame: newFrame)
                    page.delegate = self
                    scrollView.addSubview(page)
                    pagesCached.append(page)
                }
            }
        }
        setOffsetScrollView()
        scrollToCurrentTime(startHour: start)
        showCurrentLineHour()
    }
    
    @objc func startDraggingCurrentTimeLine(_ sender:UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .recognized {
            self.movingDragView = true
            imageViewDrag.image = #imageLiteral(resourceName: "dragBig")

        }
        if sender.state == .failed || sender.state == .cancelled ||  sender.state == .ended {
            self.movingDragView = false
            imageViewDrag.image = #imageLiteral(resourceName: "dragHandle")
            let nextDate = Date()
            if let time = self.getTimelineLabel(hour: nextDate.hour) {
                self.updateTimeLabelPosition(time: time)
            }
        }
        self.bringSubviewToFront(self.viewDrag)
        let translation = sender.translation(in: self)
        if self.viewDrag.center.y + translation.y > self.scrollView.contentSize.height - 70 || self.viewDrag.center.y + translation.y < 10 { return }
        self.viewDrag.center = CGPoint(x: self.viewDrag.center.x + translation.x, y: self.viewDrag.center.y + translation.y)
        imageViewDrag.center = CGPoint(x: imageViewDrag.center.x + translation.x, y: imageViewDrag.center.y + translation.y)
        self.viewDrag.frame.origin.x  = currentTimeLabel.frame.width + style.timeline.offsetTimeX + style.timeline.offsetLineLeft
        imageViewDrag.frame.origin.x = self.scrollView.frame.width - 30
        sender.setTranslation(CGPoint.zero, in: self)
        if self.scrollView.contentOffset.y + self.scrollView.frame.height - 120 <  self.viewDrag.frame.minY && self.scrollView.contentSize.height - 80 > self.viewDrag.frame.minY {
            self.isBottomEdge = true
            self.autoScrollAnimationTimer()
//            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
//               self.scrollView.contentOffset.y = self.scrollView.contentOffset.y + 4
//              }, completion: { _ in
//            })
        }
        else if self.viewDrag.frame.minY - 20 < self.scrollView.contentOffset.y && self.viewDrag.frame.minY > 50 {
            self.isTopEdge = true
            self.autoScrollAnimationTimer()
//            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
//               self.scrollView.contentOffset.y = self.scrollView.contentOffset.y - 4
//              }, completion: { _ in
//            })
        }
        else {
            self.stopScrollTimer()
        }
        self.timeLineChanged(sender)
    }
    
    private func timeLineChanged(_ sender:UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .recognized {
            self.movingDragView = true
            imageViewDrag.image = #imageLiteral(resourceName: "dragBig")
        }
        if sender.state == .failed || sender.state == .cancelled ||  sender.state == .ended {
            self.movingDragView = false
            imageViewDrag.image = #imageLiteral(resourceName: "dragHandle")
            let nextDate = Date()
            if let time = self.getTimelineLabel(hour: nextDate.hour) {
                self.updateTimeLabelPosition(time: time)
            }
        }
        var point = sender.location(in: scrollView)
        let imageViewDragPoint = sender.location(in: self.imageViewDrag)
        let time = calculateChangeTime(pointY: ((point.y - style.timeline.offsetEvent)-imageViewDragPoint.y) + self.imageViewDrag.frame.height/2 - 7.5)
        if let minute = time.minute, let hour = time.hour {
            isEnabledAutoScroll = false
            point.x -= eventPreviewXOffset
            if sender.state == .ended, let date = self.selectedDate {
                //self.delegate?.didTimeLineChangedFinished(to: date.initialHour().adding(hour: hour).adding(minutes: minute), with: self.allEvents)
            }
            else {
                guard let date = self.selectedDate else { return }
                self.delegate?.didTimeLineChanged(to: date.initialHour().adding(hour: hour).adding(minutes: minute), with: self.allEvents, onDragging: self.movingDragView)
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        headerView.layer.mask = mask
    }
}

extension TimelineView: EventPageDelegate {
    func didSelectEvent(_ event: Event, gesture: UITapGestureRecognizer) {
        delegate?.didSelectEvent(event, frame: gesture.view?.frame)
    }
    
    func didStartMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: scrollView)
        
        shadowView.removeFromSuperview()
        if let frame = moveShadowView(pointX: point.x) {
            shadowView.frame = frame
            scrollView.addSubview(shadowView)
        }
    
        eventPreview = nil
        eventPreview = EventPageView(event: eventPage.event,
                                     style: style,
                                     frame: CGRect(origin: CGPoint(x: point.x - eventPreviewXOffset, y: point.y - eventPreviewYOffset), size: eventPreviewSize))
        eventPreview?.alpha = 0.9
        eventPreview?.tag = tagEventPagePreview
        eventPreview?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        if let eventTemp = eventPreview {
            scrollView.addSubview(eventTemp)
            showChangeMinutes(pointY: point.y)
            UIView.animate(withDuration: 0.3) {
                self.eventPreview?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
    
    func didEndMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer) {
        eventPreview?.removeFromSuperview()
        eventPreview = nil
        movingMinutesLabel.removeFromSuperview()
        shadowView.removeFromSuperview()
        
        var point = gesture.location(in: scrollView)
        let leftOffset = style.timeline.widthTime + style.timeline.offsetTimeX + style.timeline.offsetLineLeft
        guard scrollView.frame.width >= (point.x + 30), (point.x - 10) >= leftOffset else { return }
        
        let pointTempY = (point.y - eventPreviewYOffset) - style.timeline.offsetEvent - 6
        let time = calculateChangeTime(pointY: pointTempY)
        if let minute = time.minute, let hour = time.hour {
            isEnabledAutoScroll = false
            point.x -= eventPreviewXOffset
            delegate?.didChangeEvent(eventPage.event, minute: minute, hour: hour, point: point)
        }
    }
    
    func didChangeMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: scrollView)
        let leftOffset = style.timeline.widthTime + style.timeline.offsetTimeX + style.timeline.offsetLineLeft
        guard scrollView.frame.width >= (point.x + 20), (point.x - 20) >= leftOffset else { return }
        
        var offset = scrollView.contentOffset
        if (point.y - 80) < scrollView.contentOffset.y, (point.y - eventPreviewSize.height) >= 0 {
            // scroll up
            offset.y -= 5
            scrollView.setContentOffset(offset, animated: false)
        } else if (point.y + 80) > (scrollView.contentOffset.y + scrollView.bounds.height), point.y + eventPreviewSize.height <= scrollView.contentSize.height {
            // scroll down
            offset.y += 5
            scrollView.setContentOffset(offset, animated: false)
        }
        
        eventPreview?.frame.origin = CGPoint(x: point.x - eventPreviewXOffset, y: point.y - eventPreviewYOffset)
        showChangeMinutes(pointY: point.y)
        
        if let frame = moveShadowView(pointX: point.x) {
            shadowView.frame = frame
        }
    }
    
    private func showChangeMinutes(pointY: CGFloat) {
        movingMinutesLabel.removeFromSuperview()
        
        let pointTempY = (pointY - eventPreviewYOffset) - style.timeline.offsetEvent - 6
        let time = calculateChangeTime(pointY: pointTempY)
        if style.timeline.offsetTimeY > 50, let minute = time.minute, 0...59 ~= minute {
            let offset = eventPreviewYOffset - style.timeline.offsetEvent - 6
            movingMinutesLabel.frame =  CGRect(x: style.timeline.offsetTimeX, y: (pointY - offset) - style.timeline.heightTime,
                                               width: style.timeline.widthTime, height: style.timeline.heightTime)
            scrollView.addSubview(movingMinutesLabel)
            movingMinutesLabel.text = ":\(minute)"
        }
    }
    
    private func calculateChangeTime(pointY: CGFloat) -> (hour: Int?, minute: Int?) {
        let times = scrollView.subviews.filter({ ($0 is TimelineLabel) }).compactMap({ $0 as? TimelineLabel })
        guard let time = times.first( where: { $0.frame.origin.y >= pointY }) else { return (nil, nil) }

        let firstY = time.frame.origin.y - (style.timeline.offsetTimeY + style.timeline.heightTime)
        let percent = (pointY - firstY) / (style.timeline.offsetTimeY + style.timeline.heightTime)
        let newMinute = Int(60.0 * percent)
        return (time.tag - 1, newMinute)
    }
    
    private func moveShadowView(pointX: CGFloat) -> CGRect? {
        guard type == .week else { return nil }
        
        let lines = scrollView.subviews.filter({ $0.tag == tagVerticalLine })
        var width: CGFloat = 200
        if let firstLine = lines[safe: 0], let secondLine = lines[safe: 1] {
            width = secondLine.frame.origin.x - firstLine.frame.origin.x
        }
        guard let line = lines.first(where: { $0.frame.origin.x...($0.frame.origin.x + width) ~= pointX }) else { return nil }
        
        return CGRect(origin: line.frame.origin, size: CGSize(width: width, height: line.bounds.height))
    }
    
    func setVisibilityEventIcon() {
        self.delegate?.setVisibilityEventIcon(with: ((self.scrollView.contentOffset.y + self.scrollView.bounds.size.height >= self.viewDrag.frame.maxY) && self.scrollView.contentOffset.y < self.viewDrag.frame.maxY))
    }
}

extension TimelineView: CalendarSettingProtocol {
    func reloadFrame(_ frame: CGRect) {
        var currentFrame = self.frame
        currentFrame.size = frame.size
        self.frame = currentFrame
        
        var scrollFrame = frame
        scrollFrame.origin.y = self.headerView.frame.maxY + 20//0
        scrollFrame.size.height -= self.headerView.frame.height//0
        scrollView.frame = scrollFrame
        
        scrollView.contentSize.width = frame.size.width
        var viewFrame = self.viewDrag.frame
        viewFrame.size.width = scrollView.contentSize.width - 15
        self.viewDrag.frame = viewFrame
        imageViewDrag.frame.origin.x = self.scrollView.frame.width - 30
    }
    
    func updateStyle(_ style: Style) {
        self.style = style
    }
}

extension TimelineView: AllDayEventDelegate {
    func didSelectAllDayEvent(_ event: Event, frame: CGRect?) {
        delegate?.didSelectEvent(event, frame: frame)
    }
}

extension TimelineView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.movingDragView || self.viewDrag.frame.height == 0.0 { return }
        self.setVisibilityEventIcon()
    }

}
