//
//  AddActivityTagViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddActivityTagViewController {
    
    func showPredictedTags() {
        guard let user = Session.shared.readUser(), !self.textToPredict.isEmpty else {
            if !self.defaultTags.isEmpty {
                self.predictionTitles = self.defaultTags
                self.predictionCollectionView.reloadData()
                self.updatePredictedTagCollectionViewHeight()
            }
            return
        }
        self.viewPredictionTags.isHidden = false
        self.startFindingPredictionTags()
        PredictionActivityTagService().getPredictedTags(user, from: self.textToPredict) { (predictionTag, id, error) in
            self.stopFindingPredictionTags()
            let allPredectionTags = predictionTag + self.defaultTags
            self.buttonAddAll.isHidden = allPredectionTags.isEmpty
            if !allPredectionTags.isEmpty {
                self.predictionTitles = allPredectionTags
                self.predictionId = id
            }
            else {
                self.predictionTitles.removeAll()
            }
        }
    }
    
    func sendPredictionFeedback() {
        guard let id = self.predictionId else { return }
        PredictionActivityTagService().sendPredictionFeedback(from: self.titles, id: id) { (status, error) in
            if status { }
            else { }
        }
    }
}
