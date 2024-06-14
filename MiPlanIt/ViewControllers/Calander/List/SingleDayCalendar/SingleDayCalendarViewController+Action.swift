//
//  SingleDayCalendarViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 28/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension SingleDayCalendarViewController {
    
    func initialiseCalendar() {
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.setStyle(self.createStyle())
        self.calendarView.set(type: .day, date: self.selectedDate, fromMonthDaySelection: true)
    }
    func initialiseUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        self.calendarView.reloadData()
        self.initialiseList(self.viewCalendarList)
    }
    
    func initialiseList(_ list: UsersListView) {
        list.bubbleAlignment = .center
        list.bubbleDirection = .leftToRight
        list.distanceInterBubbles = -10
        list.maxNumberOfBubbles = 50
        list.colorForBubbleTitles = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        list.colorForBubbleBorders = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        self.viewCalendarList.showCalendarColor = true
        list.backgroundColor = .clear//UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func createStyle() -> Style {
        var style = Style()
        style.timeline.startFromFirstEvent = false
        style.timeline.timeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)// #colorLiteral(red: 0.2705882353, green: 0.2705882353, blue: 0.2705882353, alpha: 1)
        style.timeline.currentLineHourColor = #colorLiteral(red: 1, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        style.timeline.heightLine = 1.0
        style.timeline.offsetLineRight = 100
        style.timeline.eventFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 13)!
        style.timeline.timeFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 12)!
        style.timeline.currentLineHourFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 12)!
        style.timeline.widthTime = 40
        style.timeline.offsetTimeX = 2
        style.timeline.offsetLineLeft = 2
        style.timeline.offsetTimeY = 66
        style.timeline.offsetEvent = 3
        style.timeline.currentLineHourWidth = 40
        style.allDay.isPinned = true
        style.allDay.height = 20
        style.allDay.backgroundColor = .clear//.white
        style.allDay.titleColor = .white
        style.allDay.offset = 1
        style.startWeekDay = .sunday
        style.timeHourSystem = .twelveHour
        style.event.isEnableMoveEvent = false
        
        style.headerScroll.titleDays = ["S","M","T","W","T","F","S"]
        style.headerScroll.colorTitleDate = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        style.headerScroll.heightHeaderWeek = 0
        style.headerScroll.isDotNeeded = false
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = DateFormatters.EEEEMMMDDYYYY
        style.headerScroll.formatterTitle = dateFormat
        style.headerScroll.colorWeekdayBackground = .clear
        style.headerScroll.colorBackgroundSelectDate = #colorLiteral(red: 226/255.0, green: 88/255.0, blue: 90/255.0, alpha: 1)
        style.headerScroll.colorBackground = .clear
        style.headerScroll.colorBackgroundCurrentDate = #colorLiteral(red: 226/255.0, green: 88/255.0, blue: 90/255.0, alpha: 1)
        style.headerScroll.colorSelectDate = .white
        style.headerScroll.colorNameDay = #colorLiteral(red: 0.5843137255, green: 0.5764705882, blue: 0.5803921569, alpha: 1)
        style.headerScroll.colorDate = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        style.headerScroll.colorWeekendDate = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        return style
    }
}
