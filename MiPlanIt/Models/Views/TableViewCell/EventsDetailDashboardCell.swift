//
//  EventsDetailDashboardCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class EventsDetailDashboardCell: UITableViewCell {
    
    var index: IndexPath!
    
    @IBOutlet weak var labelEventName: UILabel!
    @IBOutlet weak var labelEventTime: UILabel!
    @IBOutlet weak var labelEventCalendar: UILabel!
    @IBOutlet weak var viewCalendarColor: UIView!
    @IBOutlet weak var viewInviteeList: UsersListView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imageViewOrganizer: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewInviteeList.bubbleAlignment = .right
        self.viewInviteeList.maxNumberOfBubbles = 2
        self.viewInviteeList.distanceInterBubbles = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(event: DashboardEventItem, index: IndexPath, dateSection: DashBoardSection) {
        guard let planItEvent = event.planItEvent else { self.isHidden = true; return }
        self.isHidden = false
        self.labelEventName.text = planItEvent.readValueOfEventName()
        var startTime = Strings.empty
        var endTime = Strings.empty
        if dateSection == .tomorrow || dateSection == .today {
            if let planItEvent = event.planItEvent, planItEvent.isAllDay {
                startTime = "All Day"
            }
            else {
                startTime = event.start.stringFromDate(format: DateFormatters.HMMSA)
                endTime = event.end.stringFromDate(format: DateFormatters.HMMSA)
            }
        }
        else {
            if let planItEvent = event.planItEvent, planItEvent.isAllDay {
                startTime = event.start.stringFromDate(format: DateFormatters.EEECMMMSDD) + ", " + "All Day"
            }
            else {
                startTime = event.start.stringFromDate(format: DateFormatters.EEEMMDDHMMA)
                endTime = event.end.stringFromDate(format: DateFormatters.HMMSA)
            }
        }
        self.labelEventTime.text = startTime + (endTime.isEmpty ? Strings.empty : " - \(endTime)" )
        self.labelEventCalendar.text = event.calendar?.readValueOfCalendarName()
        self.viewCalendarColor.backgroundColor = Storage().readCalendarColorFromCode(event.calendar?.readValueOfColorCode())
        if let image = event.calendar?.readCalendarImage() {
            self.imageViewOrganizer.isHidden = false
            if let urlImage = image.0 {
                self.imageViewOrganizer.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.imageViewOrganizer.image = image.1
            }
        }
        else {
            self.imageViewOrganizer.isHidden = true
        }
    }

}
