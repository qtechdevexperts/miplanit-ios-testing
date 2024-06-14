//
//  InviteesDragView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class InviteesDragView: UIView {
    
    let kCONTENT_XIB_NAME = "InviteesDragView"
    var calenderUser: CalendarUser!
    var indexPath: IndexPath?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    
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
    
    convenience init(calenderUser: CalendarUser, frame: CGRect, profileImage: UIImage?, index: IndexPath?) {
        self.init(frame: frame)
        self.calenderUser = calenderUser
        self.labelUserName.text = calenderUser.name
        self.imageView.image = profileImage
        self.imageView.cornurRadius = 18.0
        self.indexPath = index
    }
}
