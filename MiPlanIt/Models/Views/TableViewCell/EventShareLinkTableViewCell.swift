//
//  EventShareLinkTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol EventShareLinkTableViewCellDelegate: class {
    func eventShareLinkTableViewCell(_ EventShareLinkTableViewCell: EventShareLinkTableViewCell, shareLink: PlanItShareLink, onDeleteIndex index: IndexPath)
    func eventShareLinkTableViewCell(_ EventShareLinkTableViewCell: EventShareLinkTableViewCell, shareLink: PlanItShareLink, warningItem index: IndexPath)
}

class EventShareLinkTableViewCell: UITableViewCell {
    
    weak var delegate: EventShareLinkTableViewCellDelegate?
    var shareLink: PlanItShareLink!
    var indexPath: IndexPath!
    
    @IBOutlet weak var labelEventName: UILabel!
    @IBOutlet weak var labelInviteeEmail: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelCreatedDate: UILabel!
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var viewWarning: UIView?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.delegate?.eventShareLinkTableViewCell(self, shareLink: self.shareLink, onDeleteIndex: self.indexPath)
    }
    
    @IBAction func warningButtonClicked(_ sender: UIButton) {
        self.delegate?.eventShareLinkTableViewCell(self, shareLink: self.shareLink, warningItem: self.indexPath)
    }
    
    
    func configCell(_ shareLink: PlanItShareLink, delegate: EventShareLinkTableViewCellDelegate, index: IndexPath) {
        self.indexPath = index
        self.shareLink = shareLink
        self.delegate = delegate
        self.labelEventName.text = shareLink.readEventName()
        self.labelInviteeEmail.text = shareLink.readInviteeEmail()
        self.labelCreatedDate.text = shareLink.readCreatedDate()
        self.labelStatus.text = shareLink.readStatus()
        self.labelStatus.textColor = shareLink.isEpired() ?? true ? UIColor.red : UIColor.init(red: 114/255, green: 158/255, blue: 94/255, alpha: 1.0)
        self.viewWarning?.isHidden = shareLink.readWarning().isEmpty
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
