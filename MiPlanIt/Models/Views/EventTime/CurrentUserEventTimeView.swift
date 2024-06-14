//
//  CurrentUserEventTimeView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CurrentUserEventTimeView: UIView {
    
    let kCONTENT_XIB_NAME = "CurrentUserEventTimeView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelEventName: UILabel!
    
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
    }
    
    
    func setEventName(_ name: String) {
        self.labelEventName.text = name
    }

}
