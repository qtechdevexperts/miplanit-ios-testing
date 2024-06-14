//
//  ToDoCategoryListViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar
import PINRemoteImage

protocol ToDoCategoryListViewCellDelegate: AnyObject {
    func toDoCategoryListViewCell(_ toDoCategoryListViewCell: ToDoCategoryListViewCell, sharedUserClicked indexPath: IndexPath!)
}

class ToDoCategoryListViewCell: UITableViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: ToDoCategoryListViewCellDelegate?
    
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var labelTooDoCount: UILabel!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var imageViewSharedBy: UIImageView!
    @IBOutlet weak var buttonSharedUser: UIButton!
    
    @IBAction func sharedUserClicked(_ sender: UIButton) {
        self.delegate?.toDoCategoryListViewCell(self, sharedUserClicked: self.indexPath)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ category: PlanItTodoCategory, title: String, delegate: ToDoCategoryListViewCellDelegate, indexPath: IndexPath) {
        self.delegate = delegate
        self.indexPath = indexPath
        self.labelCategoryName.text = category.readCategoryName()
        let incompletedToDoCount = category.readAllAvailableMainTodos().filter({ !$0.completed })
        self.labelTooDoCount.text = "\(incompletedToDoCount.count)"//totalactiveToDo.count == 0 ? Strings.empty :
        self.labelTooDoCount.isHidden = false//totalactiveToDo.count == 0
        let sharedByUser = category.readSharedByUser()
        self.buttonSharedUser.isHidden = category.readAllInvitees().count == 0
        self.constraintBottomOffset.constant = 0
        self.imageViewSharedBy.isHidden = true
        if let sharedBy = sharedByUser, sharedBy.readValueOfUserId() != Session.shared.readUserId(), title != Strings.mylist {
            self.imageViewSharedBy.isHidden = false
            self.imageViewSharedBy.pinImageFromURL(URL(string: sharedBy.readValueOfProfileImage()), placeholderImage: sharedBy.fullName?.shortStringImage())
        }
    }

    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
