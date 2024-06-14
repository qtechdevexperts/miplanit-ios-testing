//
//  DashBoardListMainViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashBoardListMainViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.pageControl.currentPage = page == 0 ? 4 : page < 6 ? page - 1 : 0
        if page == 0 || page == 6 {
            let actualPage = page == 0 ? 5 : 1
            self.collectionView.scrollToItem(at: IndexPath(item: actualPage, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func initComponent() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updatePageControl() {
        self.pageControl.currentPage = self.selectedItemIndex
    }
    
//    func addBlurEffect() {
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.viewContainer.addSubview(blurEffectView)
//    }
}
