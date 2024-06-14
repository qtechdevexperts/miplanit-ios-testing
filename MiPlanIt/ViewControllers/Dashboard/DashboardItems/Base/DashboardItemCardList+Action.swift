//
//  DashboardItemDetailList+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardItemCardList {
    
    func initComponent() {
        //set size of cards
        self.showingCards = self.readAllCards()
        self.layout.gesturesEnabled = true
        let size = CGSize(width: self.bounds.width, height: self.bounds.height*0.80)
        setCardSize(size)
        delegate = self
        datasource = self
        //configuration of stacks
        layout.topStackMaximumSize = 40
        layout.bottomStackMaximumSize = 30
        layout.bottomStackCardHeight = 45.0
        self.collectionView.reloadData()
    }
    
    func readAllCards() -> [CardView] {
        return Storage().getAllDashboardCards().map({ CardView(dashboardCard: $0) })
    }
    
    func updateCardSize() {
        if layout.cardSize.height == self.bounds.height*0.80 { return }
        let size = CGSize(width: self.bounds.width, height: self.bounds.height*0.80)
        setCardSize(size)
        self.collectionView.reloadData()
    }
    
    //This method should be called when new card added
    open func newCardAdded() {
        layout.newCardDidAdd(datasource!.numberOfCards(in: collectionView!) - 1)
    }

    //method to change animation speed
    open func setAnimationSpeed(_ speed: Float) {
        collectionView!.layer.speed = speed
    }
    
    //method to set size of cards
    open func setCardSize(_ size: CGSize) {
        layout.cardSize = size
    }
    
    func moveCardUp() {
        if layout.index > 0 {
            layout.index -= 1
        }
    }
    
    func moveCardDown() {
        if layout.index <= datasource!.numberOfCards(in: collectionView!) - 1 {
            layout.index += 1
        }
    }

    open func deleteCard() {
        layout.cardDidRemoved(layout.index)
    }
    
    func updateCardToDoOverDueData(on data: [PlanItTodo], type: DashBoardTitle, section: DashBoardSection) {
        if let index = self.showingCards.firstIndex(where: { return $0.dashboardCard.dashBoardTitle == type}) {
            self.showingCards[index].activeDateSection = section
            self.showingCards[index].updateOverdueData(data)
            let indexPath = IndexPath(item: index, section: 0)
            if index < self.collectionView.numberOfItems(inSection: 0), let cell = self.collectionView.cellForItem(at: indexPath) as? DashBoardCardViewCell {
                cell.updateOverDueDataCountOfTodo()
            }
        }
    }
    
    func updateCardData(on data: [Any], type: DashBoardTitle, section: DashBoardSection) {
        if let index = self.showingCards.firstIndex(where: { return $0.dashboardCard.dashBoardTitle == type}) {
            self.showingCards[index].activeDateSection = section
            self.showingCards[index].updateData(data: data)
            let indexPath = IndexPath(item: index, section: 0)
            if index < self.collectionView.numberOfItems(inSection: 0), let cell = self.collectionView.cellForItem(at: indexPath) as? DashBoardCardViewCell {
                cell.updateItemsDataList(type)
            }
        }
    }
}


extension DashboardItemCardList : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let datasource = datasource else {
            return 0
        }
        return datasource.numberOfCards(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return datasource!.card(collectionView, cardForItemAtIndex: indexPath)
    }
    
}



extension DashboardItemCardList : CardStackDatasource {
    func numberOfCards(in cardStack: CardStackView) -> Int {
        return self.showingCards.count
    }
    
    func card(_ cardStack: CardStackView, cardForItemAtIndex index: IndexPath) -> CardStackViewCell {
        let cell = cardStack.dequeueReusableCell(withReuseIdentifier: "dashBoardCardViewCell", for: index) as! DashBoardCardViewCell
        cell.configCell(cardView: self.showingCards[index.row], index: index, delegate: self, updateType: self.showingCards.first?.dashboardCard.dashBoardTitle)
        return cell
    }
    
}

extension DashboardItemCardList: CardStackDelegate {
    
    func cardStackViewLayoutSwipeDown(_ cardStackViewLayout: CardStackViewLayout) {
        let removedCard = self.showingCards.remove(at: 0)
        self.deleteCard()
        self.showingCards.append(removedCard)
        self.newCardAdded()
    }
    
    func cardDidChangeState(_ cardIndex: Int) {
        // Method to observe card postion changes
    }
}
