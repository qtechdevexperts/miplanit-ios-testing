//
//  ViewScrollViewContainer.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class TimeSlotViewContainer: UIView {

    var userResizableView: RKUserResizableView?
    var timeslotScrollView: UIScrollView?
    
    func setUserResizableView(userResizableView: RKUserResizableView, scrollView: UIScrollView) {
        self.userResizableView = userResizableView
        self.timeslotScrollView = scrollView
    }

}
