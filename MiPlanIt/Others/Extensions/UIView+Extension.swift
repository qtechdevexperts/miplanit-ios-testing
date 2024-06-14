//
//  UIView+Extension.swift
//  MiPlanIt
//
//  Created by Rajesh on 22/05/2023.
//  Copyright © 2023 Arun. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientBackground(colors: [UIColor], startPoint: CAGradientLayer.Point = .topCenter, endPoint: CAGradientLayer.Point = .bottomCenter) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}


// MARK: - Gradient
extension CAGradientLayer {
    
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
}


extension UITextField {
    @objc dynamic var defaultPlaceholderColor: UIColor? {
        get { return nil }
        set {
            guard let newValue = newValue else { return }
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: newValue
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: attributes)
        }
    }
}
func showAlertWithTwoButtons( inViewController: UIViewController, title: String, message: String, completion:@escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertaction) in
        completion()
    }))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    
    inViewController.present(alert, animated: true, completion: {
    })
}
