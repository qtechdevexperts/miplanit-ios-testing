//
//  ShoppingDateSelectionView.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShoppingDateSelectionViewDelegate: class {
    func shoppingDateSelectionView(_ shoppingDateSelectionView: ShoppingDateSelectionView, shoppingDate: ShoppingDate)
}

class ShoppingDateSelectionView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ShoppingDateSelectionViewDelegate?
    
    var shoppingDates: [ShoppingDate] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shoppingDates = [ShoppingDate(title: "All", isSelected: true, type: .all, icon: "all"),
                               ShoppingDate(title: "Today", type: .today, icon: "today"),
                              ShoppingDate(title: "Tomorrow", type: .tomorrow, icon: "tomorrow"),
                              ShoppingDate(title: "Upcoming", type: .upcoming, icon: "upcoming"),
                              ShoppingDate(title: "Completed",  type: .completed, icon: "completed")]
    }
    
    func setDelagte(delegate: ShoppingDateSelectionViewDelegate) {
        self.delegate = delegate
    }
    
    func clearSelection() {
        self.shoppingDates.forEach { (model) in
            model.isSelected = false
        }
    }

}

extension ShoppingDateSelectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shoppingDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = self.shoppingDates[indexPath.row].title.size(withAttributes: [NSAttributedString.Key.font : UIFont(name: Fonts.SFUIDisplayRegular, size: 14)!])
        return CGSize(width: (itemSize.width < 50 ? 50 : itemSize.width)+20, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.cell, for: indexPath) as! ShoppingDateCollectionCell
        cell.configureCell(self.shoppingDates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.clearSelection()
        self.shoppingDates[indexPath.row].isSelected = true
        self.collectionView.reloadData()
        self.delegate?.shoppingDateSelectionView(self, shoppingDate: self.shoppingDates[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
//        if indexPath.row > 3 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                collectionView.selectItem(at: IndexPath(item: indexPath.row-4, section: 0), animated: false, scrollPosition: .left)
//                self.clearSelection()
//                self.shoppingDates[indexPath.row-4].isSelected = true
//                self.collectionView.reloadData()
//                collectionView.scrollToItem(at: IndexPath(item: indexPath.row-4, section: 0), at: .left, animated: false)
//            }
//        }
    }
}
