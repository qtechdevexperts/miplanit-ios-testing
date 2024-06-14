//
//  DashboardCardViewGiftCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCardViewGiftCell: UITableViewCell {

    var redColorFont: UIColor = UIColor(red: 243/255, green: 119/255, blue: 91/255, alpha: 1.0)
    var normalColorFont: UIColor = UIColor(red: 118/255, green: 136/255, blue: 150/255, alpha: 1.0)
    
    @IBOutlet weak var labelGiftCardName: UILabel!
    @IBOutlet weak var labelExpiryDate: UILabel!
    @IBOutlet weak var labelIssuedby: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(gift: DashboardGiftItem, index: IndexPath, dateSection: DashBoardSection) {
        self.labelGiftCardName.text = gift.title
        let expiryDate = gift.exipryDate?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
        if dateSection == .today {
            self.labelExpiryDate.text = Strings.expiresToday
            self.labelExpiryDate.textColor = self.redColorFont
        }
        else if dateSection == .tomorrow {
            self.labelExpiryDate.text = Strings.expiresTomorrow
            self.labelExpiryDate.textColor = self.normalColorFont
        }
        else {
            self.labelExpiryDate.text = expiryDate
            self.labelExpiryDate.textColor =  self.normalColorFont
            if let expiry = gift.exipryDate?.initialHour() {
                self.labelExpiryDate.text = expiry.initialHour() == Date().initialHour() ? Strings.expiresToday : expiry.initialHour() < Date().initialHour() ? "Expired on \(expiryDate ?? "")" : "Expires on \(expiryDate ?? "")"
                self.labelExpiryDate.textColor =  expiry <= Date().initialHour() ? self.redColorFont : self.normalColorFont
            }
        }
        let issuedBy = gift.issuedBy.isEmpty ? Strings.empty :  "Issued by "+gift.issuedBy
        self.labelIssuedby.text = (!(self.labelExpiryDate.text ?? Strings.empty).isEmpty && !issuedBy.isEmpty ? ", " : Strings.empty ) + issuedBy
    }

}
