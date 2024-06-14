//
//  ShoppingItemTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

class ShoppingItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewOption: UIImageView!
    @IBOutlet weak var labelOptionName: UILabel!
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(optionType: ShoppingItemOptionList) {
        self.labelOptionName.text = optionType.name
        self.imageViewOption?.image = optionType.isBaseList ? UIImage(named: optionType.image) : UIImage(named: optionType.image)
        self.imageViewOption?.layer.cornerRadius = optionType.isBaseList ? 0.0 : 15.0
//        self.imageViewOption?.image = UIImage(named: optionType.image)
    }
    
    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
