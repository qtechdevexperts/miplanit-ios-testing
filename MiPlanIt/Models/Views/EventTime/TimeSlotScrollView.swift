//
//  TimeSlotScrollView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class TimeSlotScrollView: UIScrollView {
    
    var userResizableView: RKUserResizableView!

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.tag == 99 {
            return false
        }
        else {
            return true
        }
    }
}
