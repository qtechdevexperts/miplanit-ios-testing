//
//  CalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imgExpired: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(_ acount: PlanItSocialUser, indexPath: IndexPath) {
        self.labelOptionTitle.text = acount.readUserInformations()
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.imgExpired.isHidden = !acount.isAccountExpired()
    }
}
