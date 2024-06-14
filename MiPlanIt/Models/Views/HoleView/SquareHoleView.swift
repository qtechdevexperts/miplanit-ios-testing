//
//  SquareHoleView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SquareHoleView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
//        let radius: CGFloat = myRect.size.width
        
    }
    
    func cropRect(_ rect: CGRect) {
        self.layer.mask?.removeFromSuperlayer()
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        let circleLayer = CAShapeLayer()
        //assume the circle's radius is 150
        circleLayer.frame = CGRect(x:0 , y:0,width: self.frame.size.width,height: self.frame.size.height)
        let finalPath = UIBezierPath(roundedRect: CGRect(x:0 , y:0,width: self.frame.size.width,height: self.frame.size.height), cornerRadius: 0)
        let rectanglePath =  UIBezierPath(roundedRect: rect, cornerRadius: 5)
        finalPath.append(rectanglePath.reversing())
        circleLayer.path = finalPath.cgPath
        circleLayer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
        circleLayer.borderWidth = 1
        maskLayer.addSublayer(circleLayer)
        self.layer.mask = maskLayer
    }

}
