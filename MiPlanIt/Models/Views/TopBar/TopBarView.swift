//
//  TopBarView.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 17/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
class TopBarView: UIView {

    @IBOutlet weak var viewGradient: UIView?
    @IBOutlet weak var viewGradientCorner: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if let view = viewGradient {
            view.setGradientBackground(colors: [.clear])
            
//            view.createGradientLayer(colours: [#colorLiteral(red: 110/255.0, green: 184/255.0, blue: 198/255.0, alpha: 1), #colorLiteral(red: 72/255.0, green: 166/255.0, blue: 184/255.0, alpha: 1), #colorLiteral(red: 37/255.0, green: 147/255.0, blue: 169/255.0, alpha: 1)], locations: nil,startPOint: CGPoint(x: 1.0, y: 0.5), endPoint: CGPoint(x: 0.0, y: 0.5))
        }
        if let view2 = viewGradientCorner {
            view2.createGradientLayer(colours: [#colorLiteral(red: 110/255.0, green: 184/255.0, blue: 198/255.0, alpha: 1), #colorLiteral(red: 72/255.0, green: 166/255.0, blue: 184/255.0, alpha: 1), #colorLiteral(red: 37/255.0, green: 147/255.0, blue: 169/255.0, alpha: 1)], locations: nil,startPOint: CGPoint(x: 1.0, y: 0.5), endPoint: CGPoint(x: 0.0, y: 0.5))
        }
         super.draw(rect)
    }
}
