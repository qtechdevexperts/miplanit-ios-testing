//
//  DashBoardViewController+TileFlowLayout.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit


public class HorizontalFlowLayout: UICollectionViewLayout {
    var itemSize = CGSize(width: 0, height: 0) {
        didSet {
            invalidateLayout()
        }
    }
    private var cellCount = 0
    private var boundsSize = CGSize(width: 0, height: 0)
    var searchEnabled: Bool = false

    public override func prepare() {
        cellCount = self.collectionView!.numberOfItems(inSection: 0)
        boundsSize = self.collectionView!.bounds.size
    }
    public override var collectionViewContentSize: CGSize {
        let verticalItemsCount = Int(floor(boundsSize.height / self.getItemHeight()))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        
        let itemsPerPage = (verticalItemsCount == 0 ? 1 : verticalItemsCount) * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0...(cellCount-1) {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = self.computeLayoutAttributesForCellAt(indexPath: indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return computeLayoutAttributesForCellAt(indexPath: indexPath)
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    private func computeLayoutAttributesForCellAt(indexPath:IndexPath)
        -> UICollectionViewLayoutAttributes {
            let row = indexPath.row
            let bounds = self.collectionView!.bounds

            let verticalItemsCount = Int(floor(boundsSize.height / self.getItemHeight()))
            let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
            let itemsPerPage = (verticalItemsCount == 0 ? 1 : verticalItemsCount) * horizontalItemsCount

            let columnPosition = row % horizontalItemsCount
            let rowPosition = (row/horizontalItemsCount)%(verticalItemsCount == 0 ? 1 : verticalItemsCount)
            let itemPage = Int(floor(Double(row)/Double(itemsPerPage)))

            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            frame.origin.x = (CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * itemSize.width) + (columnPosition == 0 ? 0 : (self.searchEnabled ? 10 : 17))
            frame.origin.y = ((CGFloat(rowPosition) * self.getItemHeight())) + (rowPosition == 0 ? 0 : (self.searchEnabled ? 10 : 20))
            frame.size = self.searchEnabled ? CGSize(width: itemSize.width, height: self.getItemHeight()) : itemSize
            attr.frame = frame

            return attr
    }
    
    func getItemHeight() -> CGFloat {
        return self.searchEnabled ? itemSize.height - 15 : itemSize.height
    }
}
