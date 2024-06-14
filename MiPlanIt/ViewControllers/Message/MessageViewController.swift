//
//  MessageViewController.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    var removed: Bool = false
    var caption: String? = Strings.empty
    var errorDescription: String? = Strings.empty

    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var imageViewError: UIImageView!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var constraintsTopOfViewHolder: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageCaptionsAndDescriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showErrorMessageScreen(true)
        self.removeMessageCaptionAfterFewSeconds()
        super.viewDidAppear(animated)
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.removeMessageFromWindow()
    }
}
