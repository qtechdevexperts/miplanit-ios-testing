//
//  CalendarInvitiesTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CalendarInvitiesTableViewCellDelegate: class {
    func calendarInvitiesTableViewCellSwipedAccess(_ calendarInvitiesTableViewCell: CalendarInvitiesTableViewCell)
    func calendarInvitiesTableViewCellSwipedDelete(_ calendarInvitiesTableViewCell: CalendarInvitiesTableViewCell)
}


class CalendarInvitiesCell: UITableViewCell {
    
    weak var delegate: CalendarInvitiesTableViewCellDelegate?
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(_ user: User, vc: CalendarInvitiesTableViewCellDelegate) {
        self.user = user
        self.delegate = vc
    }

}
