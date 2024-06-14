//
//  CalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar
protocol CalendarTableViewCellDelegate: class {
    func calendarTableViewCell(_ userTableViewCell: CalendarTableViewCell, sharedUserClicked users: [CalendarUser], planItCalendar: PlanItCalendar)
}

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var viewInviteeList: UsersListView!
    @IBOutlet weak var viewVisibility: UIView?
    @IBOutlet weak var buttonPrivate: UIButton?
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var viewSocialEmailAccount: UIView?
    @IBOutlet weak var labelSocialEmailAccount: UILabel?
    @IBOutlet weak var imageViewColor: UIImageView!
    @IBOutlet weak var buttonShare: UIButton?
    var indexPath: IndexPath!
    weak var delegate: CalendarTableViewCellDelegate?
    var calendarModel: Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewInviteeList.bubbleAlignment = .left
        self.viewInviteeList.distanceInterBubbles = -6
    }
    
    override func prepareForReuse() {
        self.imageViewOptionIcon.image = nil
        super.prepareForReuse()
    }
    
    @IBAction func sharedUserClicked(_ sender: UIButton) {
        if let userCalendarVisibility = self.calendarModel as? UserCalendarVisibility {
            self.delegate?.calendarTableViewCell(self, sharedUserClicked: userCalendarVisibility.readAllShareUserList(), planItCalendar: userCalendarVisibility.calendar)
        }
        else if let calendarUser = self.calendarModel as? CalendarUser, let calendar = calendarUser.planItCalendarShared {
            self.delegate?.calendarTableViewCell(self, sharedUserClicked: calendarUser.readAllShareUserList(), planItCalendar: calendar)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(item: UserCalendarVisibility, indexPath: IndexPath, calendarType: String, delegate: CalendarTableViewCellDelegate? = nil) {
        self.calendarModel = item
        self.delegate = delegate
        self.indexPath = indexPath
        self.imageViewTick.image = !item.selected ? ( item.disabled ? #imageLiteral(resourceName: "selectCalendarDisabledOnIcon") :  #imageLiteral(resourceName: "selectCalendarOffIcon")) : #imageLiteral(resourceName: "selectCalendarOnIcon")
        let calendarName = item.calendar.readValueOfCalendarName()
        self.labelOptionTitle.text = calendarName
//        self.labelOptionTitle.textColor = item.selected ? .white : UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.imageViewColor.backgroundColor = Storage().readCalendarColorFromCode(item.calendar.readValueOfColorCode())
        self.labelSocialEmailAccount?.text = (!item.calendar.readValueOfSocialAccountEmail().isEmpty && (item.calendar.readValueOfCalendarType() == "1" ||  item.calendar.readValueOfCalendarType() == "2")) ? "\(Strings.ac)\n\(item.calendar.readValueOfSocialAccountEmail())" : Strings.empty
        self.viewSocialEmailAccount?.isHidden = self.labelSocialEmailAccount?.text?.isEmpty ?? true
        self.viewVisibility?.isHidden = calendarType == "0"
        self.imageViewOptionIcon.contentMode = .scaleAspectFit
        if let image = item.calendar.readCalendarImage(isFromEventDetailView: true) {
            if let urlImage = image.0 {
                self.imageViewOptionIcon.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.imageViewOptionIcon.image = image.1
            }
        }
        var invitees: [Any] = item.calendar.readAllCalendarInvitees()
        if let createdBy = item.calendar.createdBy, createdBy.readValueOfUserId() != Session.shared.readUserId() {
            invitees.append(createdBy)
        }
        self.buttonShare?.isHidden = item.readAllShareUserList().count <= 1
    }
    
    func configureCell(item: CalendarUser, isSelected: Bool, indexPath: IndexPath, delegate: CalendarTableViewCellDelegate? = nil) {
        self.calendarModel = item
        self.delegate = delegate
        self.indexPath = indexPath
        self.imageViewTick.image = !isSelected ? ( item.isDisabled ? #imageLiteral(resourceName: "selectCalendarDisabledOnIcon") :  #imageLiteral(resourceName: "selectCalendarOffIcon")) : #imageLiteral(resourceName: "selectCalendarOnIcon")
        self.labelOptionTitle.text = item.planItCalendarShared?.readValueOfCalendarName()
//        self.labelOptionTitle.textColor = isSelected ? .white : UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.imageViewColor.backgroundColor = Storage().readCalendarColorFromCode(item.planItCalendarShared?.readValueOfColorCode())
        self.viewVisibility?.isHidden = true
        self.viewSocialEmailAccount?.isHidden = true
        self.imageViewOptionIcon.contentMode = .scaleAspectFit
        if let image = item.planItCalendarShared?.readCalendarImage() {
            if let urlImage = image.0 {
                self.imageViewOptionIcon.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.imageViewOptionIcon.image = image.1
            }
        }
        var invitees: [Any] = item.planItCalendarShared?.readAllCalendarInvitees() ?? []
        if let createdBy = item.planItCalendarShared?.createdBy, createdBy.readValueOfUserId() != Session.shared.readUserId() {
            invitees.append(createdBy)
        }
        self.buttonShare?.isHidden = item.readAllShareUserList().count <= 1
    }
    
    @IBAction func switchValueChanged(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.isSelected = !sender.isSelected
        }
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
