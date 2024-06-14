//
//  BasicCell.swift
//  MyPagerCollView
//
//  Created by Leela Prasad on 08/03/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

class BasicCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Fonts.SFUIDisplayMedium, size: 14)!
        return lbl
    }()
    
    var indicatorView: UIView!

//    override var isSelected: Bool {
//
//        didSet{
//            UIView.animate(withDuration: 0.30) {
//                self.indicatorView.backgroundColor = self.isSelected ? Color(red: 149/255, green: 85/255, blue: 182/255, alpha: 1.0) : UIColor.clear
//                self.layoutIfNeeded()
//            }
//        }
//
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        addConstraintsWithFormatString(formate: "H:|[v0]|", views: titleLabel)
        addConstraintsWithFormatString(formate: "V:|[v0]|", views: titleLabel)
        
        addConstraint(NSLayoutConstraint.init(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        setupIndicatorView()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    func configCell(category: ShopSubCategoryAndItems) {
        self.titleLabel.text = category.categoryName
        self.titleLabel.textColor = category.isSelected ? Color(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0) : Color(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0)
        self.indicatorView.backgroundColor = category.isSelected ? Color(red: 96/255, green: 201/255, blue: 220/255, alpha: 1.0) : UIColor.clear
    }
   
    func setupIndicatorView() {
        indicatorView = UIView()
        addSubview(indicatorView)
        
        addConstraintsWithFormatString(formate: "H:|[v0]|", views: indicatorView)
        addConstraintsWithFormatString(formate: "V:[v0(3)]|", views: indicatorView)
    }
    
}
