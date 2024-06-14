//
//  DashboardItemDetailList.swift
//  MiPlanIt
//
//  Created by fsadmin on 03/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

public typealias CardStackView = UICollectionView
public typealias CardStackViewCell = UICollectionViewCell

public protocol CardStackDelegate  {
    func cardDidChangeState(_ cardIndex: Int)
    func cardStackViewLayoutSwipeDown(_ cardStackViewLayout: CardStackViewLayout)
}

public protocol CardStackDatasource  {
    func numberOfCards(in cardStack: CardStackView) -> Int
    func card(_ cardStack: CardStackView, cardForItemAtIndex index: IndexPath) -> CardStackViewCell
}

protocol DashboardItemCardListDelegate: class {
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, selectedItem: Any)
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, expandCard card: CardView)
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, openOverDue card: CardView)
}

class DashboardItemCardList: UIView {
    
    var layout: CardStackViewLayout {
        let layout = self.collectionView.collectionViewLayout as! CardStackViewLayout
        return layout
    }
    var delegate: CardStackDelegate? {
        didSet {
            layout.delegate = delegate
        }
    }
    var datasource: CardStackDatasource?
    var currentShowingCard :CardView?
    var showingCards: [CardView] = [] {
        didSet {
            self.currentShowingCard = showingCards.first
        }
    }

    var previousView: UIView! = nil
    var currentView: UIView! = nil
    var nextView: UIView! = nil
    var currentIndex = 0

    var offset: CGFloat = CGFloat()
    var dashBoardItemData: [DashboardPendingItem] = []
    weak var itemDetailDelegate: DashboardItemCardListDelegate?
    
    @IBOutlet var viewDashboardItems: [DashboardPendingItemsView]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setupViews(delegate: DashboardItemCardListDelegate) {
        self.itemDetailDelegate = delegate
        self.initComponent()
    }
    
}
