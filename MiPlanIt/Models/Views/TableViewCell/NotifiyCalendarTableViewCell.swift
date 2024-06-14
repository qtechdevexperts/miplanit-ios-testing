//
//  NotifiyCalendarTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class NotifiyCalendarTableViewCell: UITableViewCell {
    
    var userCalendar: UserCalendarVisibility!
    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var viewVisibility: UIView?
    @IBOutlet weak var buttonPrivate: UIButton?
    @IBOutlet weak var labelSocialCalendarEmail: UILabel!
    @IBOutlet weak var imageViewColor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.imageViewOptionIcon.image = nil
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(item: UserCalendarVisibility, indexPath: IndexPath, calendarType: String) {
        self.userCalendar = item
        self.imageViewTick.image = !item.selected ? #imageLiteral(resourceName: "selectCalendarOffIcon") : #imageLiteral(resourceName: "selectCalendarOnIcon")
        self.buttonPrivate?.isSelected = item.visibility == 1
        let calendarName = item.calendar.readValueOfCalendarName()
        self.labelOptionTitle.text = calendarName
        self.labelOptionTitle.textColor = item.selected ? .white : UIColor.init(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1.0)
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
    }
    
    @IBAction func switchValueChanged(_ sender: UIButton) {
        self.userCalendar.visibility = sender.isSelected ? 0 : 1
        UIView.animate(withDuration: 0.1) {
            sender.isSelected = !sender.isSelected
        }
    }
}
