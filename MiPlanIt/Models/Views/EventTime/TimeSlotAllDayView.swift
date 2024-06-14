//
//  TimeSlotAllDayView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class TimeSlotAllDayView: UIView {

    let kCONTENT_XIB_NAME = "TimeSlotAllDayView"
    var event: Any?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelEventName: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
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
    
    func setBGColorFor(_ event: Any) {
        self.viewContainer.backgroundColor = (event is OtherUserEvent) ? UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 0.9) : UIColor(red: 255/255, green: 192/255, blue: 187/255, alpha: 1.0)
    }
    
    
    func setEventName(_ name: String, event: Any) {
        self.labelEventName.text = name
        self.setBGColorFor(event)
        self.event = event
    }

}
