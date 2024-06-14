//
//  RequestNotificationTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol RequestNotificationCellDelegate: class {
    func requestNotificationCell(_ requestNotificationCell: RequestNotificationTableViewCell, update notification: UserNotification, withAction action: ProcessingButton)
    func requestNotificationCell(_ requestNotificationCell: RequestNotificationTableViewCell, showDetail notification: UserNotification)
}

class RequestNotificationTableViewCell: UITableViewCell {
    
    var notification: UserNotification!
    weak var delegate: RequestNotificationCellDelegate?
    
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var labelRecievedTime: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var imageViewActionIcon: UIImageView?
    @IBOutlet weak var labelActionLabel: UILabel?
    @IBOutlet weak var buttonMarkAsRead: ProcessingButton?
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.imageViewProfile.image = #imageLiteral(resourceName: "profilePic")
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(_ notification: UserNotification, indexPath: IndexPath, callback: RequestNotificationCellDelegate) {
        self.delegate = callback
        self.notification = notification
        self.labelActionLabel?.text = notification.readNotificationStatusLabel()
        self.labelRecievedTime.text = notification.createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)?.convertDateToComponents() ?? "-- hours ago"
        self.setNotificationContent()
        self.downloadUserProfileImageFromServer()
    }
    
    func setNotificationContent() {
        switch self.notification.readNotificationAction() {
        case 1:
            self.showUserNotificationMessageContent()
        case 2:
            self.showDeletedNotificationMessageContent()
        case 3:
            self.showUpdatedNotificationMessageContent()
        case 4:
            self.showFullAccessUserNotificationMessageContent()
        case 5:
            self.showCompletedNotificationMessageContent()
        case 6:
            self.showRemovalNotificationMessageContent()
        case 101:
            self.showReplayNotificationMessageContent()
        default: break
        }
    }
    
    
    func updateTextLabel(string: String) -> NSAttributedString{
        return NSAttributedString().getAttrStrOf(string:string, font: self.notification.readNotificationUserStatus() == 4 ? self.readNormalMessageFont() : self.readActionMessageFont())
    }
    
    func showUserNotificationMessageContent() {
        switch self.notification.readNotificationStatus() {
        case 0, 4:
            if self.notification.readNotificationStatus() == 4 || self.notification.isExpiredEvent() {
                self.imageViewActionIcon?.image = #imageLiteral(resourceName: "expire-icon")
                self.labelActionLabel?.text = Strings.expired
                let labelString = NSMutableAttributedString()
                labelString.append(updateTextLabel(string:"Invitation for "))
                labelString.append(updateTextLabel(string: self.notification.activityTypeLabel))
                labelString.append(updateTextLabel(string:" - "))
                labelString.append(updateTextLabel(string: self.notification.activityTitle))
                labelString.append(updateTextLabel(string:" from "))
                labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
                labelString.append(updateTextLabel(string:" has been expired."))
                self.labelContent.attributedText = labelString
                self.labelContent.textColor = .white
            }
            else {
                let labelString = NSMutableAttributedString()
                let eventDate = self.notification.notificationEvent?.readStartDateTimeString() ?? self.notification.readStartDateString()
                labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.creator?.fullName ?? Strings.empty, font: self.readActionMessageFont()))
                if self.notification.readActvityType() == 5 {
                    labelString.append(updateTextLabel(string:" has assigned a "))
                }
                else {
                    labelString.append(updateTextLabel(string:" is inviting you to the "))
                }
                labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTypeLabel, font: self.readActionMessageFont()))
                labelString.append(updateTextLabel(string:" - "))
                labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTitle, font: self.readActionMessageFont()))
                labelString.append(updateTextLabel(string:" on "))
                labelString.append(NSAttributedString().getAttrStrOf(string: eventDate, font: self.readActionMessageFont()))
                self.labelContent.attributedText = labelString
                self.labelContent.textColor = .white
            }
        case 1:
            self.imageViewActionIcon?.image = #imageLiteral(resourceName: "approved-icon")
            let labelString = NSMutableAttributedString()
            labelString.append(updateTextLabel(string:"You accepted "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTypeLabel, font: self.readNormalMessageFont()))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTitle, font: self.readNormalMessageFont()))
            labelString.append(updateTextLabel(string:" invitation from "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.creator?.fullName ?? Strings.empty, font: self.readNormalMessageFont()))
            self.labelContent.attributedText = labelString
            self.labelContent.textColor = .white

        case 2:
            self.imageViewActionIcon?.image = #imageLiteral(resourceName: "rejected-icon")
            let labelString = NSMutableAttributedString()
            labelString.append(updateTextLabel(string:"You rejected "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTypeLabel, font: self.readNormalMessageFont()))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.activityTitle, font: self.readNormalMessageFont()))
            labelString.append(updateTextLabel(string:" invitation from "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.creator?.fullName ?? Strings.empty, font: self.readNormalMessageFont()))
            self.labelContent.attributedText = labelString
            self.labelContent.textColor = .white

        default: break
        }
    }
    
    func showDeletedNotificationMessageContent() {
        self.imageViewActionIcon?.image = #imageLiteral(resourceName: "removedNot")
        self.labelActionLabel?.text = Strings.deleted
        let labelString = NSMutableAttributedString()
        let subActivityTitles = self.notification.readSubActivityTitles()
        if self.notification.readActvityType() == 7, !subActivityTitles.isEmpty {
            // shop item deleted
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            if subActivityTitles.count > 1 {
                labelString.append(updateTextLabel(string:" has deleted \(subActivityTitles.count) items "))
                labelString.append(updateTextLabel(string:" in the Shopping List - "))
            }
            else {
                labelString.append(updateTextLabel(string:" has deleted item "))
                labelString.append(updateTextLabel(string: (subActivityTitles.first ?? Strings.empty) ))
                labelString.append(updateTextLabel(string:" in the Shopping List - "))
            }
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
        }
        else {
            labelString.append(updateTextLabel(string:"You have been removed from "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
            labelString.append(updateTextLabel(string:" by "))
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
        }
        self.labelContent.attributedText = labelString
        self.labelContent.textColor = .white

    }
    
    func showUpdatedNotificationMessageContent() {
        self.imageViewActionIcon?.image = #imageLiteral(resourceName: "updatedNot")
        self.labelActionLabel?.text = Strings.updated
        let labelString = NSMutableAttributedString()
        labelString.append(updateTextLabel(string:"The "))
        labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
        labelString.append(updateTextLabel(string:" - "))
        labelString.append(updateTextLabel(string:self.notification.activityTitle))
        labelString.append(updateTextLabel(string:" has been updated by "))
        labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
        self.labelContent.attributedText = labelString
        self.labelContent.textColor = .white

    }
    
    func showFullAccessUserNotificationMessageContent() {
        self.imageViewActionIcon?.image = self.notification.readNotificationUserStatus() == 4 ? #imageLiteral(resourceName: "approved-icon") :  #imageLiteral(resourceName: "info")
        self.labelActionLabel?.text = self.notification.readNotificationStatusLabel()
        let labelString = NSMutableAttributedString()
        let subActivityTitles = self.notification.readSubActivityTitles()
        if self.notification.readActvityType() == 7, !subActivityTitles.isEmpty {
            // shop item add
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            if subActivityTitles.count > 1 {
                labelString.append(updateTextLabel(string:" has added \(subActivityTitles.count) new items"))
            }
            else {
                labelString.append(updateTextLabel(string:" has added new item "))
                labelString.append(updateTextLabel(string: (subActivityTitles.first ?? Strings.empty) ))
            }
            labelString.append(updateTextLabel(string:" in shopping list - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
        }
        else if self.notification.readActvityType() == 8 {
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            labelString.append(updateTextLabel(string:" added an "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            if let subActivity = self.notification.readSubActivityTitles().first {
                labelString.append(updateTextLabel(string:" - "))
                labelString.append(updateTextLabel(string: subActivity))
            }
            labelString.append(updateTextLabel(string:" to your calendar - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
        }
        else if self.notification.readActvityType() == 9, let notificationEvent = self.notification.notificationEvent, let registedUser = notificationEvent.isRegisteredUser {
            let eventStartDateTime = self.notification.notificationEvent?.readBookingEventStartDateTimeString() ?? self.notification.readStartDateString()
            let eventEndDateTime = self.notification.notificationEvent?.readBookingEventEndDateTimeString() ?? self.notification.readStartDateString()
            let email = registedUser ? self.notification.creator?.fullName ?? Strings.empty : notificationEvent.sharedEmail
            labelString.append(NSAttributedString().getAttrStrOf(string: email, font: self.readActionMessageFont()))
            labelString.append(updateTextLabel(string:" has created an event on "))
            labelString.append(NSAttributedString().getAttrStrOf(string: self.notification.createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)?.stringFromDate(format: DateFormatters.DDSMMMSYYYY) ?? self.notification.createdAt, font: self.readActionMessageFont()))
            labelString.append(updateTextLabel(string:" from "))
            labelString.append(NSAttributedString().getAttrStrOf(string: eventStartDateTime+" - "+eventEndDateTime, font: self.readActionMessageFont()))
            labelString.append(updateTextLabel(string:" using the share event link."))
        }
        else {
            labelString.append(updateTextLabel(string:"You have been added to the "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
            labelString.append(updateTextLabel(string:" by "))
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
        }
        self.labelContent.attributedText = labelString
        self.labelContent.textColor = .white

    }
    
    func showCompletedNotificationMessageContent() {
        let labelString = NSMutableAttributedString()
        self.imageViewActionIcon?.image = #imageLiteral(resourceName: "approved-icon")
        let subActivityTitles = self.notification.readSubActivityTitles()
        if self.notification.readActvityType() == 7, !subActivityTitles.isEmpty {
            // shop item completed
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            if subActivityTitles.count > 1 {
                labelString.append(updateTextLabel(string:" has completed \(subActivityTitles.count) items "))
            }
            else {
                labelString.append(updateTextLabel(string:" has completed item "))
                labelString.append(updateTextLabel(string: (subActivityTitles.first ?? Strings.empty) ))
            }
            labelString.append(updateTextLabel(string:" in the Shopping List - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
        }
        else {
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            labelString.append(updateTextLabel(string:" has completed the "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
        }
        self.labelContent.attributedText = labelString
        self.labelContent.textColor = .white

    }
    
    func showRemovalNotificationMessageContent() {
        let labelString = NSMutableAttributedString()
        self.imageViewActionIcon?.image = #imageLiteral(resourceName: "approved-icon")
        labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
        labelString.append(updateTextLabel(string:"  is no longer a participant of the "))
        labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
        labelString.append(updateTextLabel(string:" - "))
        labelString.append(updateTextLabel(string:self.notification.activityTitle))
        self.labelContent.attributedText = labelString
        self.labelContent.textColor = .white

    }
    
    func showReplayNotificationMessageContent() {
        let labelString = NSMutableAttributedString()
        if self.notification.readNotificationStatus() == 1 {
            self.imageViewActionIcon?.image = #imageLiteral(resourceName: "approved-icon")
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            labelString.append(updateTextLabel(string:"  has accepted the "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
            self.labelContent.attributedText = labelString
            self.labelContent.textColor = .white

        }
        else {
            self.imageViewActionIcon?.image = #imageLiteral(resourceName: "rejected-icon")
            labelString.append(updateTextLabel(string:self.notification.creator?.fullName ?? Strings.empty))
            labelString.append(updateTextLabel(string:" has rejected the "))
            labelString.append(updateTextLabel(string:self.notification.activityTypeLabel))
            labelString.append(updateTextLabel(string:" - "))
            labelString.append(updateTextLabel(string:self.notification.activityTitle))
            self.labelContent.attributedText = labelString
            self.labelContent.textColor = .white

        }
    }
    
    func readNormalMessageFont() -> UIFont {
        return UIFont(name: Fonts.SFUIDisplayRegular, size: 17)!
    }
    
    func readActionMessageFont() -> UIFont {
        return UIFont(name: Fonts.SFUIDisplayMedium, size: 17)!
    }
    
    @IBAction func ignoredButtonClicked(_ sender: ProcessingButton) {
        self.delegate?.requestNotificationCell(self, update: self.notification, withAction: sender)
    }
    
    @IBAction func acceptButtonClicked(_ sender: ProcessingButton) {
        self.delegate?.requestNotificationCell(self, update: self.notification, withAction: sender)
    }
    
    @IBAction func markasReadButtonClicked(_ sender: ProcessingButton) {
        if self.notification.isPossibleToUpdateMarkAsRead() {
            self.delegate?.requestNotificationCell(self, update: self.notification, withAction: sender)
        }
        else {
            self.delegate?.requestNotificationCell(self, showDetail: self.notification)
        }
    }
    
    func downloadUserProfileImageFromServer() {
        self.imageViewProfile.pinImageFromURL(URL(string: self.notification.creator?.profileImage ?? Strings.empty), placeholderImage: self.notification.creator?.fullName.shortStringImage(1))
    }
    
    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

