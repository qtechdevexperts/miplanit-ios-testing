//
//  ShowPopInfoViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShowPopInfo {
    var mainString: String? = Strings.empty
    var subString: String? = Strings.empty
    var image: UIImage?
    var imageStartPoint: CGPoint!
    init(imageStartPoint: CGPoint, main: String?, sub: String? = Strings.empty) {
        self.mainString = main
        self.subString = sub
        self.imageStartPoint = imageStartPoint
    }
}

class ShowPopInfoViewController: UIViewController {
    
    var frameStartPoint: CGPoint!
    var topSafeArea: CGFloat = 0.0
    var showPopInfo: ShowPopInfo!
    
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewBlurContainer: UIView!
    @IBOutlet weak var labelMainString: UILabel!
    @IBOutlet weak var labelSubString: UILabel!
    
    @IBAction func closeWIndow(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelMainString.text = self.showPopInfo.mainString
        self.labelSubString.text = self.showPopInfo.subString
        self.imageView.image = self.showPopInfo.image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
        self.imageView.frame = CGRect(x: self.showPopInfo.imageStartPoint.x, y: self.showPopInfo.imageStartPoint.y+topSafeArea, width: 50, height: 50)
    }
    
    override func viewDidLayoutSubviews() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.viewBlurContainer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewBlurContainer.addSubview(blurEffectView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.viewContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
         }) { (finished) in
            UIView.animate(withDuration: 0.1, animations: {
              self.viewContainer.transform = CGAffineTransform.identity // undo in 1 seconds
           })
        }
    }
    
}
