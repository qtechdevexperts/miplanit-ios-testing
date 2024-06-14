//
//  TimeSlotViewController+ResizableViewDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension TimeSlotViewController: RKUserResizableViewDelegate {
    
    func userResizableViewOnChangingPosition(_ userResizableView: RKUserResizableView, point: CGPoint) {
        self.updateTimeAndEventView(userResizableView)
    }
    
    func userResizableViewDidBeginEditing(_ userResizableView: RKUserResizableView, point: CGPoint) {
        self.scrollView.isScrollEnabled = false
        currentlyEditingView?.hideEditingHandles()
        currentlyEditingView = userResizableView
    }
    
    @objc func userResizableViewDidEndEditing(_ userResizableView: RKUserResizableView, point: CGPoint) {
        self.scrollView.isScrollEnabled = true
        lastEditedView = userResizableView
        self.updateTimeAndEventView(userResizableView, onEnd: true)
        self.updateInviteeStatus()
    }
    
    @objc func userResizableViewOnDragging(_ userResizableView: RKUserResizableView, point: CGPoint) {
        let changedPoint = self.viewBottom.convert(point, from:self.view)
        if self.viewBottom.bounds.contains(changedPoint) {
            if point.y+self.scrollView.contentOffset.y < self.scrollContentSize.height {
                self.incrementContentOffset()
            }
        }
        else {
            let changedPoint = self.viewTop.convert(point, from:self.view)
            if self.viewTop.bounds.contains(changedPoint) {
                if self.scrollView.contentOffset.y > 0 {
                    self.decrementContentOffset()
                }
            }
        }
        self.updateTimeAndEventView(userResizableView)
    }
}
