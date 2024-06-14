//
//  ShopAttachmentPopUp.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import UIKit

class ShopAttachmentPopUp: UIViewController {
    
    var shopListItemCellModel: ShopListItemCellModel!
    
    @IBOutlet weak var constraintViewContainer: NSLayoutConstraint!
    @IBOutlet weak var viewCollectionContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageViewItemImage: UIImageView!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var textViewNotes: UITextView!
    @IBOutlet weak var viewGradient: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.constraintViewContainer.constant = UIScreen.main.bounds.size.height
        super.viewWillAppear(animated)
    }
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
        self.dismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHidePopUpOptions(true)
        self.setGradientBackground()
        super.viewDidAppear(animated)
    }
}
