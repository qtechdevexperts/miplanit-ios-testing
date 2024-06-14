//
//  SharedViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension SharedViewController {
    func initialiseUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
