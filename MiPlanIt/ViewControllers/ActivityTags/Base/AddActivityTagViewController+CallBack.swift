//
//  AddActivityTagViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddActivityTagViewController: ActivityAddTagCollectionViewCellDelegate {
    
    func activityAddTagCollectionViewCell(_ cell: ActivityAddTagCollectionViewCell, checkExisting tag: String) -> Bool {
        return self.titles.contains(where: {$0.caseInsensitiveCompare(tag) == .orderedSame})
    }
    
    
    func activityAddTagCollectionViewCell(_ cell: ActivityAddTagCollectionViewCell, addedNewTag tag: String) {
        guard self.canAddTag else { return }
        self.titles.append(tag)
    }
}

extension AddActivityTagViewController: ActivityTagCollectionViewCellDelegate {
    
    func activityTagCollectionViewCell(_ cell: ActivityTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath) {
        guard self.canAddTag else { return }
        self.titles.remove(at: indexPath.row)
        self.reloadPredictedCollection()
    }
    
    func activityTagCollectionViewCell(_ cell: ActivityTagCollectionViewCell, addPredictedTag indexPath: IndexPath) {
        guard self.canAddTag else { return }
        if self.verifyPredictedTag(index: indexPath.row) {
            self.titles.append(self.predictionTitles[indexPath.row].text)
        }
        self.reloadPredictedCollection()
    }
}
