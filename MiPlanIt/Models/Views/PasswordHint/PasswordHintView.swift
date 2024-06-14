//
//  PasswordHintView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

class PasswordHintView: UIView {
    
    let kCONTENT_XIB_NAME = "PasswordHintView"
    var isErrorHint: Bool = false
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelHint: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        contentView.backgroundColor = .clear
    }
    
    func setDefaultView(with index: Int) {
        self.imageView.image =  UIImage(named: "icon_tick_grey")
        self.labelHint.textColor = .white// UIColor.init(red: 144/255, green: 144/255, blue: 144/255, alpha: 1.0)
        var hintText = "Password must have at least 8 characters"
        switch index {
        case 1:
            hintText = "Must have at least 1 number"
        case 2:
            hintText = "Must have a special character"
        case 3:
            hintText = "Must have 1 upper case letter"
        case 4:
            hintText = "Must have 1 lower case letter"
        default:
            hintText = "Password must have at least 8 characters"
        }
        self.labelHint.text = hintText
        self.isErrorHint = true
    }
    
    func setWrongView() {
        self.isErrorHint = true
        self.imageView.image =  UIImage(named: "icon_wrong_red")
        self.labelHint.textColor =  UIColor.init(red: 227/255, green: 115/255, blue: 115/255, alpha: 1.0)
    }
    
    func setRightView() {
        self.isErrorHint = false
        self.imageView.image =  UIImage(named: "icon_tick_green")
        self.labelHint.textColor =  UIColor.init(red: 148/255, green: 196/255, blue: 125/255, alpha: 1.0)
    }
    
}
