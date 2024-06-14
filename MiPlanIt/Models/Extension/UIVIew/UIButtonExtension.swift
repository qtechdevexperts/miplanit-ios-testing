//
//  UIButtonExtension.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    @IBInspectable var underlined: Bool {
        get {
            return false
        }
        set {
            if newValue {
                if self.titleLabel != nil {
                    let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
                    attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                  value: NSUnderlineStyle.single.rawValue,
                                                  range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
                    self.setAttributedTitle(attributedString, for: .normal)
                }
            }
        }
    }
    
    
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
    
    func startPulseAnimation() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.85
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 100
        pulse.initialVelocity = 0.6
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
    
    func removeAllLayerAnimations() {
        self.layer.removeAllAnimations()
        self.layoutIfNeeded()
    }
}

