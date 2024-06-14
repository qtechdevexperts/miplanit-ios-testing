//
//  InviteesStatusTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class InviteesStatusTableViewCell: UITableViewCell {
    
    var user: OtherUser!

    @IBOutlet weak var imageViewProfileView: UIImageView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var labelInviteeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: OtherUser) {
        self.user = user
        self.labelInviteeName.text = !user.fullName.isEmpty ? user.fullName : (!user.phone.isEmpty ? user.phone : (user.email))
        self.setStatusColor()
        self.downloadUserProfileImageFromServer()
    }
    
    func setStatusColor() {
        switch self.user.currentStatus {
        case .eAvailable:
            self.viewStatus.backgroundColor = .green
        case .eBusy, .eAway:
            self.viewStatus.backgroundColor = .red
        default:
             self.viewStatus.backgroundColor = .clear
        }
    }
    
    func downloadUserProfileImageFromServer() {
        self.imageViewProfileView.pinImageFromURL(URL(string: self.user.profileImage), placeholderImage: self.user.fullName.shortStringImage(1))
    }
}
