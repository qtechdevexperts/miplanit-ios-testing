//
//  DashboardCardViewEventCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCardViewEventCell: UITableViewCell {

    @IBOutlet weak var labelEventName: UILabel!
    @IBOutlet weak var labelEventTime: UILabel!
    @IBOutlet weak var imageViewPic: UIImageView!
    @IBOutlet weak var viewInviteeList: UsersListView!
    @IBOutlet weak var imageViewOrganizer: UIImageView!
    @IBOutlet weak var viewCalendarColor: UIView!
    
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
        guard let planItEvent = event.planItEvent else { return }
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
