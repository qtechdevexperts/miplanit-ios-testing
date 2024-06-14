//
//  SelectCalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol SelectCalendarTableViewCellDelegate: AnyObject {
    func selectCalendarTableViewCell(_ selectCalendarTableViewCell: SelectCalendarTableViewCell, invitees: [Any])
}

class SelectCalendarTableViewCell: UITableViewCell {
    
    var userCalendar: UserCalendarVisibility!
    weak var delegate: SelectCalendarTableViewCellDelegate?
    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var viewInviteeList: UsersListView!
    @IBOutlet weak var viewVisibility: UIView?
    @IBOutlet weak var buttonPrivate: UIButton?
    @IBOutlet weak var labelSocialCalendarEmail: UILabel!
    @IBOutlet weak var imageViewColor: UIImageView!
    @IBOutlet weak var buttonShareList: UIButton!
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        var invitees: [Any] = self.userCalendar.calendar.isSocialCalendar() ? self.userCalendar.calendar.readAllNotifyCalendarInvitees() :  self.userCalendar.calendar.readAllCalendarInvitees()
        if let createdBy = self.userCalendar.calendar.createdBy, createdBy.readValueOfUserId() != Session.shared.readUserId() {
            invitees.append(createdBy)
        }
        self.delegate?.selectCalendarTableViewCell(self, invitees: invitees)
    }
    
    func configureCell(item: UserCalendarVisibility, indexPath: IndexPath, calendarType: String, delegate: SelectCalendarTableViewCellDelegate) {
        self.userCalendar = item
        self.delegate = delegate
        self.imageViewTick.image = !item.selected ? #imageLiteral(resourceName: "calendarSelectCircle") : #imageLiteral(resourceName: "selectCalendarIconSel")
        self.buttonPrivate?.isSelected = item.visibility == 1
        let calendarName = item.calendar.readValueOfCalendarName()
        self.labelOptionTitle.text = calendarName
        self.labelOptionTitle.textColor = item.selected ? .white : UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.imageViewColor.backgroundColor = Storage().readCalendarColorFromCode(item.calendar.readValueOfColorCode())
        self.labelSocialCalendarEmail.text = (!item.calendar.readValueOfSocialAccountEmail().isEmpty && (item.calendar.readValueOfCalendarType() == "1" ||  item.calendar.readValueOfCalendarType() == "2")) ? "\(Strings.ac)\n\(item.calendar.readValueOfSocialAccountEmail())" : Strings.empty
        self.viewVisibility?.isHidden = calendarType == "0"
        //self.viewInviteeList.isHidden = calendarType != "0"
        if let image = item.calendar.readCalendarImage() {
            if let urlImage = image.0 {
                self.imageViewOptionIcon.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.imageViewOptionIcon.image = image.1
            }
        }
        var invitees: [Any] = item.calendar.isSocialCalendar() ? item.calendar.readAllNotifyCalendarInvitees() : item.calendar.readAllCalendarInvitees()
        if let createdBy = item.calendar.createdBy, createdBy.readValueOfUserId() != Session.shared.readUserId() {
            invitees.append(createdBy)
        }
        if invitees.count > 0 {
            //self.viewInviteeList.isHidden = false
            self.buttonShareList.isHidden = false
            //self.viewInviteeList.reloadUsersListWithUsers(invitees)
        }
        else {
            //self.viewInviteeList.isHidden = true
            self.buttonShareList.isHidden = true
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UIButton) {
        self.userCalendar.visibility = sender.isSelected ? 0 : 1
        UIView.animate(withDuration: 0.1) {
            sender.isSelected = !sender.isSelected
        }
    }
}
