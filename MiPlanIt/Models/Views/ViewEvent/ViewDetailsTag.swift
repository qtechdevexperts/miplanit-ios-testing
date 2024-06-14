//
//  ViewDetailsTag.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsTag: UIView {
    
    @IBOutlet weak var collectionViewTags: UICollectionView!
    @IBOutlet weak var constraintCollectionViewTagsHeight: NSLayoutConstraint!
    
    var tags: [String] = [] {
        didSet {
            self.collectionViewTags.reloadData()
            self.updateTagCollectionViewTagsHeight()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialiseTagCollectionFlowLayout()
    }
    
    func updateTagCollectionViewTagsHeight(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.constraintCollectionViewTagsHeight.constant = self.collectionViewTags.contentSize.height
            self.layoutIfNeeded()
        }
    }
    
    func initialiseTagCollectionFlowLayout() {
        self.collectionViewTags.dataSource = self
        self.collectionViewTags.delegate = self
        let layout = TagFlowLayout()
        layout.estimatedItemSize = CGSize(width: 110, height: 40)
        self.collectionViewTags.collectionViewLayout = layout
    }
    
    func setTags(_ tags: [String]) {
        self.tags = tags
    }
}


extension ViewDetailsTag: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventTagCollectionViewCell", for: indexPath) as! EventTagCollectionViewCell
        cell.setTag(self.tags[indexPath.row])
        return cell
    }
}
