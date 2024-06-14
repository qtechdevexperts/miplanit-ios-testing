//
//  NotifiedCalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol NotifiedCalendarTableViewCellDelegate: class {
    func notifiedCalendarTableViewCell(_ userTableViewCell: NotifiedCalendarTableViewCell, sharedUserClicked users: [CalendarUser], planItCalendar: PlanItCalendar)
}
class NotifiedCalendarTableViewCell: UITableViewCell {
    var userCalendar: UserCalendarVisibility!
    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var labelSocialCalendarEmail: UILabel!
    @IBOutlet weak var imageViewColor: UIImageView!
    @IBOutlet weak var buttonShare: UIButton?
    weak var delegate: NotifiedCalendarTableViewCellDelegate?
    @IBOutlet weak var viewAssignee: UIView?
    @IBOutlet weak var imageViewAssignee: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func sharedUserClicked(_ sender: UIButton) {
        self.delegate?.notifiedCalendarTableViewCell(self, sharedUserClicked: self.userCalendar.readAllShareUserList(), planItCalendar: self.userCalendar.calendar)
    }
    
    func configureCell(item: UserCalendarVisibility, indexPath: IndexPath, delegate: NotifiedCalendarTableViewCellDelegate? = nil) {
        self.userCalendar = item
        self.delegate = delegate
        let calendarName = item.calendar.readValueOfCalendarName()
        self.labelOptionTitle.text = calendarName
        self.labelOptionTitle.textColor = item.selected ? .white : .white//UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.imageViewColor.backgroundColor = Storage().readCalendarColorFromCode(item.calendar.readValueOfColorCode())
        self.labelSocialCalendarEmail.text = (!item.calendar.readValueOfSocialAccountEmail().isEmpty && (item.calendar.readValueOfCalendarType() == "1" ||  item.calendar.readValueOfCalendarType() == "2")) ? "\(Strings.ac)\n\(item.calendar.readValueOfSocialAccountEmail())" : Strings.empty
        if let image = item.calendar.readCalendarImage() {
            if let urlImage = image.0 {
                self.imageViewOptionIcon.pinImageFromURL(urlImage, placeholderImage: image.1)
            }
            else {
                self.imageViewOptionIcon.image = image.1
            }
        }
//        var invitees: [Any] = item.calendar.readAllCalendarInvitees()
//        if let createdBy = item.calendar.createdBy, createdBy.readValueOfUserId() != Session.shared.readUserId() {
//            invitees.append(createdBy)
//        }
////        self.buttonShare?.isHidden = item.readAllShareUserList().count <= 1
        self.setAssigneOrSharedUser(calendar: item.calendar)
    }
    
    func setAssigneOrSharedUser(calendar: PlanItCalendar) {
        if let creator = calendar.createdBy {
            self.viewAssignee?.isHidden = false
            self.imageViewAssignee?.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee?.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
}
