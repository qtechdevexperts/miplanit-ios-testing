//
//  UserCalendarHeaderCell.swift
//  MiPlanIt
//
//  Created by Arun on 24/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol UserCalendarHeaderCellDelegate: AnyObject {
    func userCalendarHeaderCell(_ cell: UserCalendarHeaderCell, syncCalendarAtIndex index: Int,type:String)
}

class UserCalendarHeaderCell: UITableViewCell {
    
    var index = 0
    weak var delegate: UserCalendarHeaderCellDelegate?
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var buttonSyncCalendar: ProcessingButton?
    @IBOutlet weak var labelHeader: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureHeader(_ header: UserCalendarType, at section: Int, callback: UserCalendarHeaderCellDelegate?) {
        self.index = section
        self.delegate = callback
        self.buttonSyncCalendar?.isHidden = header.type == "0" || header.type == "4" || header.type == "5"
        self.buttonSyncCalendar?.isSelected = header.synced
        self.buttonSyncCalendar?.isUserInteractionEnabled = !header.synced
        self.setImageForHeader(header.type)
        self.labelHeader?.text = header.type == "4" || header.type == "5" ? header.label : Strings.empty
        
    }
    
    func setImageForHeader(_ calendarType: String) {
        switch calendarType {
        case "0":
            self.imgHeader.image = #imageLiteral(resourceName: "logoMiPlanItSmall")
        case "1":
            self.imgHeader.image = #imageLiteral(resourceName: "logoGoogleSmall")
        case "2":
            self.imgHeader.image = #imageLiteral(resourceName: "logoOutlookSmall")
        case "3":
            let appleImage = UIImage(named: "logoAppleSmall")
            self.imgHeader.image = appleImage
            self.imgHeader.tintColor = .white
        case "4":
            self.imgHeader.image = #imageLiteral(resourceName: "logoMiPlanItSmall")
        default:
            self.imgHeader.image = nil
            break
        }
    }
    @IBAction func syncCalanderButtonClicked(_ sender: ProcessingButton) {
        self.delegate?.userCalendarHeaderCell(self, syncCalendarAtIndex: self.index , type: "")
    }
}
