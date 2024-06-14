//
//  SwipeDrawerViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SwipeDrawerViewController: UIViewController {
    
    @IBOutlet weak var viewMenu: MenuView?
    @IBOutlet weak var viewGradientLayer: UIView?
    @IBOutlet weak var imgViewLogo: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.viewMenu != nil {
            self.addMenuSwipeGestures()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let view = viewGradientLayer {
            view.backgroundColor = .menuBackground
            
//            view.createGradientLayer(colours: [#colorLiteral(red: 53/255.0, green: 173/255.0, blue: 195/255.0, alpha: 1.0), #colorLiteral(red: 137/255.0, green: 213/255.0, blue: 227/255.0, alpha: 1.0), #colorLiteral(red: 240/255.0, green: 182/255.0, blue: 111/255.0, alpha: 1.0)], locations: [0,0.4,1.0], startPOint: CGPoint(x: 0.2, y: 0.0), endPoint: CGPoint(x: 0.8, y: 1.0))
        }
    }
    
    func addMenuSwipeGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if !isMenu{
            guard let view = self.viewMenu else { return }
            view.showMenu(show: sender.direction == .right)
        }
      
    }
}
