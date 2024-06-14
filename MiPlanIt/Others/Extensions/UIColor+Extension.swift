//
//  UIColor+Extension.swift
//  MiPlanIt
//
//  Created by Rajesh on 22/05/2023.
//  Copyright © 2023 Arun. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    
    ///White Colors
    static let whiteLight:      UIColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    static let grayLight:       UIColor = #colorLiteral(red: 0.7568627451, green: 0.7725490196, blue: 0.8745098039, alpha: 1)
    static let grayLightPlus:   UIColor = #colorLiteral(red: 0.7058823529, green: 0.7254901961, blue: 0.8509803922, alpha: 1)
    static let menuBackground:   UIColor = #colorLiteral(red: 0.2549019608, green: 0.2509803922, blue: 0.3490196078, alpha: 1)
    static let grayMT:   UIColor = #colorLiteral(red: 0.137254902, green: 0.1450980392, blue: 0.2588235294, alpha: 1)
}

extension UIColor{
    static let primaryButtonGradient:[UIColor] = [.white, .whiteLight, .grayLight, .grayLightPlus]
}

