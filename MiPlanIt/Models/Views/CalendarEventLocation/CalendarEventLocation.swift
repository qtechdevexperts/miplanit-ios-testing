//
//  CalendarEventLocation.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarEventLocation: UIView {
    
    let kCONTENT_XIB_NAME = "CalendarEventLocation"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelLocation: UILabel!
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
    
    func configView(event: Event) {
        self.labelLocation.text = event.getLocationName()
        self.labelEventName.text = event.text
        self.labelLocation.textColor = event.isAccepted == false ? UIColor.white: event.colorText
        self.labelEventName.textColor = event.isAccepted == false ? UIColor.white: event.colorText
        self.contentView.backgroundColor = event.backgroundColor
    }

}
