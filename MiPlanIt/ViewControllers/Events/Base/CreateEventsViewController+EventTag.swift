//
//  CreateEventsViewController+EventTagDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: EventTagCollectionViewCellDelegate {
    
    func eventTagCollectionViewCell(_ cell: EventTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath) {
        self.titles.remove(at: indexPath.row)
    }
}


extension CreateEventsViewController: EventAddTagCollectionViewCellDelegate {
    
    func eventAddTagCollectionViewCell(_ cell: EventAddTagCollectionViewCell, checkExisting tag: String) -> Bool {
        return self.eventModel.tags.contains(where: {$0.caseInsensitiveCompare(tag) == .orderedSame})
    }
    
    
    func eventAddTagCollectionViewCell(_ cell: EventAddTagCollectionViewCell, addedNewTag tag: String) {
        self.titles.append(tag)
    }
}

extension CreateEventsViewController: AddEventTagViewControllerDelegate {
 
    func addEventTagViewController(_ viewController: AddEventTagViewController, updated tags: [String]) {
        self.eventModel.tags = tags
        self.showTagsCount()
    }
}
