//
//  MessageViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension  MessageViewController {
    
    func manageCaptionsAndDescriptions() {
        self.labelCaption.text = self.caption
        self.labelDescription.text = self.errorDescription
        self.imageViewError.image = self.caption == Message.error ? #imageLiteral(resourceName: "error") : (self.caption == Message.success ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "warning"))
    }
    
    func showErrorMessageScreen(_ status: Bool) {
        self.constraintsTopOfViewHolder.constant = status ? 0 : -self.viewHolder.bounds.height
        self.view.setNeedsUpdateConstraints()
        status ? self.showAnimation() : self.hideAnimation()
    }
    
    func showAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.viewHolder.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func removeMessageCaptionAfterFewSeconds() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.removeMessageFromWindow()
        }
    }
    
    func removeMessageFromWindow() {
        guard !self.removed else { return }
        self.removed = true
        self.showErrorMessageScreen(false)
    }
}
