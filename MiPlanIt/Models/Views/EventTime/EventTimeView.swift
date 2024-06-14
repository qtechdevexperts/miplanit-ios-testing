//
//  EventTimeView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class EventTimeView: UIView {
    
    let kCONTENT_XIB_NAME = "EventTimeView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelTimeRange: UILabel!
    @IBOutlet weak var labelAmountOfTime: UILabel!
    @IBOutlet weak var labelUserNotAvailable: UILabel!
    @IBOutlet weak var labelAmountOfTimeRight: UILabel!
    @IBOutlet weak var viewTimeRange: UIStackView!
    @IBOutlet weak var viewTimeIntervalBottom: UIStackView!
    
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
    
    
    func setTime(from startDate: Date, to endDate: Date, position: EventTimeViewPosition, eventAvailableCount: Int) {
        self.labelTimeRange.text = startDate.getTime() + "-" + endDate.getTime()
        self.labelAmountOfTime.text = "(\(endDate.timeDiffrence(from: startDate)))"
        self.labelAmountOfTimeRight.text = "(\(endDate.timeDiffrence(from: startDate)))"
        switch position {
        case .inside:
            self.labelTimeRange.textColor = .white
            self.labelAmountOfTimeRight.textColor = .white
            self.labelAmountOfTime.textColor = .white
            self.labelAmountOfTime.isHidden = endDate.interval(ofComponent: .minute, fromDate: startDate) <= 30
            self.labelAmountOfTimeRight.isHidden = endDate.interval(ofComponent: .minute, fromDate: startDate) > 30
        case .outside:
            self.labelTimeRange.textColor = UIColor.init(red: 114/225, green: 114/225, blue: 114/225, alpha: 1.0)
            self.labelAmountOfTimeRight.textColor = UIColor.init(red: 114/225, green: 114/225, blue: 114/225, alpha: 1.0)
            self.labelAmountOfTime.textColor = UIColor.init(red: 114/225, green: 114/225, blue: 114/225, alpha: 1.0)
            self.labelAmountOfTime.isHidden = true
//            self.viewTimeIntervalBottom.isHidden = true
        }
        
    }

}
