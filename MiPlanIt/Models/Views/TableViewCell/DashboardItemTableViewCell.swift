//
//  DashboardItemTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardItemTableViewCell: UITableViewCell {

    var indexPath: IndexPath!
    
    @IBOutlet weak var labelEvent: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var buttonSelect: UIButton!
    @IBOutlet weak var imgPriority: UIImageView!
    @IBOutlet weak var imgRepeat: UIImageView!
    @IBOutlet weak var imgKind: UIImageView!
    @IBOutlet weak var imgKindBG: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var constraintPriorityWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCustomDashboardItem(atIndexPath indexPath: IndexPath) {
        switch indexPath.row % 4 {
        case 0:
            self.viewBG.backgroundColor = UIColor.init(red: 234/255.0, green: 247/255.0, blue: 255/255.0, alpha: 1)
            self.imgKindBG.image = UIImage(named: "event1bg")
            self.imgKind.image = UIImage(named: "event1")
            self.labelDate.text = "12 June 7:00am - 7:30am"
            self.labelDate.textColor = UIColor.init(red: 66/255.0, green: 87/255.0, blue: 100/255.0, alpha: 1)
            self.labelEvent.text = "My daily 30-minute morning workout"
            self.imgPriority.isHidden = true
            self.imgRepeat.isHidden = false
            constraintPriorityWidth.constant = 0
        case 1:
            self.viewBG.backgroundColor = UIColor.init(red: 236/255.0, green: 238/255.0, blue: 255/255.0, alpha: 1)
            self.imgKindBG.image = UIImage(named: "event2bg")
            self.imgKind.image = UIImage(named: "event2")
            self.labelDate.text = "12 June 10:30 am"
            self.labelDate.textColor = UIColor.init(red: 109/255.0, green: 117/255.0, blue: 183/255.0, alpha: 1)
            self.labelEvent.text = "Pick up laundry from Fiesta Laundries"
            self.imgPriority.isHidden = false
            self.imgRepeat.isHidden = true
        case 2:
            self.viewBG.backgroundColor = UIColor.init(red: 255/255.0, green: 234/255.0, blue: 246/255.0, alpha: 1)
            self.imgKindBG.image = UIImage(named: "event3bg")
            self.imgKind.image = UIImage(named: "event3")
            self.labelDate.text = "12 June 1:00pm - 2:30pm"
            self.labelDate.textColor = UIColor.init(red: 167/255.0, green: 110/255.0, blue: 143/255.0, alpha: 1)
            self.labelEvent.text = "Lunch with Samantha Bruce @ Fayetteville"
            self.imgPriority.isHidden = true
            self.imgRepeat.isHidden = true
            constraintPriorityWidth.constant = 0
        case 3:
            self.viewBG.backgroundColor = UIColor.init(red: 255/255.0, green: 247/255.0, blue: 231/255.0, alpha: 1)
            self.imgKindBG.image = UIImage(named: "event4bg")
            self.imgKind.image = UIImage(named: "event4")
            self.labelDate.text = "12 June 5:00pm"
            self.labelDate.textColor = UIColor.init(red: 145/255.0, green: 112/255.0, blue: 48/255.0, alpha: 1)
            self.labelEvent.text = "Weekend shopping from Harveys"
            self.imgPriority.isHidden = true
            self.imgRepeat.isHidden = true
            constraintPriorityWidth.constant = 0
        default:
            break
        }
//        self.labelStoreName.text = ""
//        self.labelPurchaseName.text = ""
//        self.labelDate.text = ""
    }

}
