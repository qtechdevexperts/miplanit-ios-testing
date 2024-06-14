//
//  DashboardItemsCollectionViewCell.swift
//  MiPlanIt
//
//  Created by fsadmin on 28/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    }
}

class DashboardItemsCollectionViewCell: UICollectionViewCell {
    
    var dashBoardItem: DashboardItems!
    
    @IBOutlet weak var labelItemCount: UILabel!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var imageViewItemIcon: UIImageView!
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var viewProcessing: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configureCell(dashBoardItem: DashboardItems, activeSection: DashBoardSection) {
        self.dashBoardItem = dashBoardItem
        self.viewGradient.createGradientLayer(colours: dashBoardItem.color, locations: nil)
        self.imageViewItemIcon.image = UIImage(named: dashBoardItem.icon)
        self.labelItemName.text = dashBoardItem.title
        self.manageDashboardItemProgress(section: activeSection)
    }
    
    func manageDashboardItemProgress(section activeSection: DashBoardSection) {
        if self.dashBoardItem.onProgress {
            if let count = Session.shared.readEachTypesSectionCount(section: activeSection, type: self.dashBoardItem.type) {
                self.activityIndicator.stopAnimating()
                self.labelItemCount.text = "\(count)"
            }
            else {
                self.activityIndicator.startAnimating()
                self.labelItemCount.text = ""
            }
        }
        else {
            self.activityIndicator.stopAnimating()
            self.labelItemCount.text = "\(dashBoardItem.items.count)"
        }
    }
    
    func createGradientView() -> UIView {
        let viewGradient = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.frame.height))
        return viewGradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateGradientLayer()
    }
    
    func updateGradientLayer() {
        guard let subLayers = self.viewGradient.layer.sublayers else { return }
        for eachLayer in subLayers where eachLayer is CAGradientLayer {
            eachLayer.frame = self.bounds
        }
    }
}

class DashboardItems: NSObject {
    
    let title: String
    let icon: String
    let color: [UIColor]
    let type: DashBoardTitle!
    var onProgress: Bool = true
    var items: [Any] = []
    
    init(title: String, icon: String, type: DashBoardTitle, color: [UIColor]) {
        self.title = title
        self.icon = icon
        self.color = color
        self.type = type
    }
}

enum GradientDirection{
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}
extension UIView{
    func gradientBackground(from color1:UIColor, to color2:UIColor, direction:GradientDirection){
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        switch direction {
        case.leftToRight:
            gradient.startPoint = CGPoint(x:0.0, y:0.5)
            gradient.endPoint = CGPoint(x:1.0, y:0.5)
        case.rightToLeft:
            gradient.startPoint = CGPoint(x:1.0, y:0.5)
            gradient.endPoint = CGPoint(x:0.0, y:0.5)
        case.bottomToTop:
            gradient.startPoint = CGPoint(x:0.5, y:1.0)
            gradient.endPoint = CGPoint(x:0.5, y:0.0)
        default:break
        }
        self.layer.insertSublayer(gradient, at:0)
    }
}

