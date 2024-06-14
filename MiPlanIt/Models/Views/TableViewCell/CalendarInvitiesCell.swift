//
//  CalendarInvitiesTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CalendarInvitiesCellDelegare: class {
    func calendarInvitiesCell(_ calendarInvitiesCell: CalendarInvitiesCell, removedUser user: CalendarUser)
}

class CalendarInvitiesCell: UITableViewCell {
    
    var user: CalendarUser!
    var section: Int = 0
    weak var delegate:CalendarInvitiesCellDelegare?
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelContact: UILabel!
    @IBOutlet weak var imageViewUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        self.imageViewUser.image = #imageLiteral(resourceName: "profilePic")
        self.labelContact.text = Strings.empty
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            for view in subviews where view.description.contains("Reorder") {
                for case let subview as UIImageView in view.subviews {
                   subview.image = UIImage(named: "icon_CalendarSwap.png")
                    subview.contentMode = .center
                }
            }
        }
    }
    
    func configure(_ user: CalendarUser, indexPath: IndexPath, callBack: CalendarInvitiesCellDelegare) {
        self.user = user
        self.delegate = callBack
        self.section = indexPath.section
        self.labelName.text = user.name
        self.labelContact.text = user.isPrivate ? Strings.empty : user.userContainsEmailInPhoneContact ? user.email : user.phone
        self.downloadUserProfileImageFromServer()
    }
    
    func downloadUserProfileImageFromServer() {
        self.imageViewUser.pinImageFromURL(URL(string: user.profile), placeholderImage: self.user.name.shortStringImage(1))
    }
    
    
    @IBAction func removeUserButtonClicked(_ sender: UIButton) {
        self.delegate?.calendarInvitiesCell(self, removedUser: self.user)
    }
}
