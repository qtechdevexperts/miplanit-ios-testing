//
//  AssignUserHeaderView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

class AssignUserHeaderView: UICollectionReusableView {

    let kCONTENT_XIB_NAME = "AssignUserHeaderView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelHeader: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
