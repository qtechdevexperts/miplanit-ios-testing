//
//  AddActivityTagViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddActivityTagViewController {
    
    func initialiseUIComponents() {
        self.buttonDone?.isHidden = !self.canAddTag
        self.labelNoTagsFound.isHidden = !(!self.canAddTag && self.tags.isEmpty)
    }
    
    func updateTagCollectionViewHeight() {
        self.collectionView.layoutIfNeeded()
        let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        self.constraintCollectionViewHeight.constant = height < 40 ? 40 : height
    }
    
    func updatePredictedTagCollectionViewHeight() {
        self.predictionCollectionView.layoutIfNeeded()
        let height = self.predictionCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.constraintPredictionCollectionViewHeight.constant = height
        self.view.layoutIfNeeded()
    }
    
    func verifyPredictedTag(index: Int) -> Bool {
        return !self.titles.contains(self.predictionTitles[index].text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func startFindingPredictionTags() {
        self.lottieAnimationView.isHidden = false
        self.lottieAnimationView.loopMode = .loop
        self.lottieAnimationView.play()
    }
    
    func stopFindingPredictionTags() {
        self.lottieAnimationView.isHidden = true
        self.lottieAnimationView.stop()
    }
    
    func reloadPredictedCollection() {
        self.predictionCollectionView.reloadData()
        self.checkForHiddingAllAddedTag()
    }
    
    func checkForHiddingAllAddedTag() {
        var hideAllTag: Bool = true
        for eachPredictedTag in self.predictionTitles {
            if !self.titles.contains(eachPredictedTag.text) {
                hideAllTag = false
                break
            }
        }
        self.buttonAddAll.isHidden = hideAllTag
    }
}
