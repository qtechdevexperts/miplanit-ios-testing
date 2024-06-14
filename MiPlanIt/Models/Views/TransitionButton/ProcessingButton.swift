//
//  ProcessingButton.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import TransitionButton
import Lottie

class ProcessingButton: TransitionButton {
    
    enum ButtonType{
        case primary
        case secondary
    }
    
    override func startAnimation() {
        super.startAnimation()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func stopAnimation(animationStyle: StopAnimationStyle = .normal, revertAfterDelay delay: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        super.stopAnimation(animationStyle: animationStyle, revertAfterDelay: delay, completion: completion)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func removeAllLottieAnimations() {
        let lotties = self.subviews.filter({ return $0 is LottieAnimationView })
        lotties.forEach({ $0.removeFromSuperview() })
    }
    
    func clearButtonTitleForAnimation() {
        self.removeAllLottieAnimations()
        self.setTitleColor(.clear, for: .normal)
        self.setTitleColor(.clear, for: .selected)
        self.setTitle(Strings.empty, for: .normal)
        self.setTitle(Strings.empty, for: .selected)
        self.setImage(nil, for: .normal)
        self.setImage(nil, for: .selected)
    }
    
    func setTitle(_ title: String, color: UIColor) {
        self.removeAllLottieAnimations()
        self.setTitle(title, for: .normal)
        self.setTitleColor(color, for: .normal)
    }
    
    func showTickAnimation(borderOnly: Bool = false, completion: @escaping(Bool)->()) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let anim = LottieAnimationView(name: (borderOnly ? "tick_violet" : "tick"))
        anim.contentMode = .scaleAspectFit
        var animFrame = self.bounds
        let buttonOrigin = self.frame.origin
        animFrame.size.width = UIScreen.main.bounds.width
        anim.frame = animFrame
        self.addSubview(anim)
        anim.center = CGPoint(x: self.center.x-buttonOrigin.x, y: self.center.y - buttonOrigin.y)
        anim.play(fromProgress: 0, toProgress: 1) { (true) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                UIApplication.shared.endIgnoringInteractionEvents()
                completion(true)
            })
        }
    }
    
    func setType(type: ButtonType){
        switch type {
        case .primary:
            self.setGradientBackground(colors: UIColor.primaryButtonGradient)
        case .secondary:
            //TODO Add secondary view here
            break
        }
    }
}
