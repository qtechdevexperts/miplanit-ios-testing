//
//  CalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit


class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var buttonShare: UIButton?
    var indexPath: IndexPath!
    
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
    
    func configureCell(item: CalendarUser, indexPath: IndexPath, isSelected: Bool) {
        self.indexPath = indexPath
        self.imageViewTick.image = !isSelected ? #imageLiteral(resourceName: "selectCalendarOffIcon") : #imageLiteral(resourceName: "selectCalendarOnIcon")
        self.labelOptionTitle.text = "\(item.name)'s MiPlaniT"
        self.labelOptionTitle.textColor = isSelected ? .white : .white//UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.downloadUserProfileImageFromServer(item)
    }
    
    func downloadUserProfileImageFromServer(_ calenderUser: Any?) {
        var profileImage: String = ""
        if let otherUser = calenderUser as? OtherUser {
            self.imageViewOptionIcon?.image = otherUser.fullName.shortStringImage(1)
            profileImage = otherUser.profileImage
        }
        else if let planItInvitees = calenderUser as? PlanItInvitees {
            self.imageViewOptionIcon?.image = planItInvitees.fullName?.shortStringImage(1)
            profileImage = planItInvitees.profileImage ?? Strings.empty
        }
        else if let calendarUser = calenderUser as? CalendarUser {
            self.imageViewOptionIcon?.image = calendarUser.name.shortStringImage(1)
            profileImage = calendarUser.profile
        }
        guard !profileImage.isEmpty else { return }
        self.imageViewOptionIcon?.pinImageFromURL(URL(string: profileImage), placeholderImage: nil)
    }
    
}
