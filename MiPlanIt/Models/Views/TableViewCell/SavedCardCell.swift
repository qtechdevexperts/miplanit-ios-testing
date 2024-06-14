//
//  SavedCardCell.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SavedCardCell: UITableViewCell {
    
    @IBOutlet weak var buttonSelectCard: UIButton!
    @IBOutlet weak var labelCardName: UILabel!
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var viewBorder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(item: UserPaymentOption, indexPath: IndexPath) {
        self.buttonSelectCard.isSelected = item.isSelected
        self.labelCardName.text = item.paymentCard.readCardName()
        self.labelCardNo.text = item.paymentCard.readCardNumber()
    }
}

