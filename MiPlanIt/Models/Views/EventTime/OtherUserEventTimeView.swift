//
//  OtherUserEventTimeView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class OtherUserEventTimeView: UIView {
    
    let kCONTENT_XIB_NAME = "OtherUserEventTimeView"
    var startDateTime: Date!
    var endDateTime: Date!
    var userId: String! = Strings.empty
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelTimeRange: UILabel!
    @IBOutlet weak var labelAmountOfTime: UILabel!
    
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
    
    func setDateTime(startDateTime: Date, endDateTime: Date, userId: String) {
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.userId = userId
    }

}
