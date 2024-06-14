//
//  CustomDashboardTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol CustomDashboardTableViewCellDelegate: class {
    func customDashboardTableViewCell(_ customDashboardTableViewCell: CustomDashboardTableViewCell, onSelect profile: CustomDashboardProfile?)
    func customDashboardTableViewCell(_ customDashboardTableViewCell: CustomDashboardTableViewCell, onLongPress profile: CustomDashboardProfile?)
}

class CustomDashboardTableViewCell: UITableViewCell {
    
    var index: IndexPath?
    var customDashboardProfile: CustomDashboardProfile?
    weak var delegate: CustomDashboardTableViewCellDelegate?
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var labelDefault: UILabel!
    @IBOutlet weak var imageViewBgCount: UIImageView!
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var buttonSelection: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
//        self.imageViewProfile.image = nil
        super.prepareForReuse()
        self.buttonSelection.gestureRecognizers?.forEach({ (gesture) in
            if gesture is UILongPressGestureRecognizer {
                self.buttonSelection.removeGestureRecognizer(gesture)
            }
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func selectButtonClicked(_ sender: Any) {
        self.delegate?.customDashboardTableViewCell(self, onSelect: self.customDashboardProfile)
    }
    
    
    func configureCell(indexPath: IndexPath, dashboard: CustomDashboardProfile, delegate: CustomDashboardTableViewCellDelegate) {
        self.index = indexPath
        self.delegate = delegate
        self.customDashboardProfile = dashboard
        self.viewUpperBorder.isHidden = false
        let count = dashboard.notificationCount > 99 ? "99+" : "\(dashboard.notificationCount)"
        self.labelCount.text = count
        self.labelDefault.isHidden = dashboard.planItDashboard.isDefault == false
        self.imageViewBgCount.image = #imageLiteral(resourceName: "gradientBG")
        self.labelName.text = dashboard.planItDashboard.readDashboardName()
        if let imageData = dashboard.planItDashboard.dashboardImageData {
            self.imageViewProfile.image = UIImage(data: imageData)
        }
        else {
            self.imageViewProfile.pinImageFromURL(URL(string: dashboard.planItDashboard.readImageURL()), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressMainUser))
        self.buttonSelection.addGestureRecognizer(longGesture)
    }
    
    @objc func longPressMainUser(gesture: UIGestureRecognizer) {
        self.delegate?.customDashboardTableViewCell(self, onLongPress: self.customDashboardProfile)
    }
    
    func configureCell(user: PlanItUser?, count: Int, dashboards: [CustomDashboardProfile], delegate: CustomDashboardTableViewCellDelegate) {
        self.delegate = delegate
        self.viewUpperBorder.isHidden = true
        self.imageViewBgCount.image = #imageLiteral(resourceName: "circlecountmain")
        let countString = count > 99 ? "99+" : "\(count)"
        self.labelCount.text = "\(countString)"
        self.labelDefault.isHidden = dashboards.contains(where: { return $0.planItDashboard.isDefault })
        if let planitUser = user {
            self.imageViewProfile.pinImageFromURL(URL(string: planitUser.readValueOfProfile()), placeholderImage: planitUser.readValueOfName().shortStringImage())
            self.labelName.text = planitUser.readValueOfName()
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressMainUser))
        self.buttonSelection.addGestureRecognizer(longGesture)
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

