//
//  CustomDashboardView.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CustomDashboardViewDelegate: class {
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, dashboardProfile: CustomDashboardProfile?)
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, longPressDashboardProfile: CustomDashboardProfile?)
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, profileImageDownload: UIImage?)
}

class CustomDashboardView: UIView {

    let kCONTENT_XIB_NAME = "CustomDashboardView"
    var dashboardProfile: CustomDashboardProfile?
    weak var delegate: CustomDashboardViewDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var buttonSelection: UIButton!
    
    @IBAction func selectionButtonCLicked(_ sender: Any) {
        self.delegate?.customDashboardViewDelegate(self, dashboardProfile: self.dashboardProfile)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressMainUser))
        self.buttonSelection.addGestureRecognizer(longGesture)
    }
    
    @objc func longPressMainUser(gesture: UIGestureRecognizer) {
        self.delegate?.customDashboardViewDelegate(self, longPressDashboardProfile: self.dashboardProfile)
    }
    
    convenience init(frame: CGRect, dashboard: CustomDashboardProfile, delegate: CustomDashboardViewDelegate) {
        self.init(frame: frame)
        self.dashboardProfile = dashboard
        self.delegate = delegate
    }
    
    func downloadImage(profileImage: Any?) {
        self.updateProfileImage(profileImage: profileImage) {
            self.delegate?.customDashboardViewDelegate(self, profileImageDownload: nil)
        }
    }
    
    func updateNotificationCount(by value: Int, updateImage: Any? = nil) {
        let stringValue = value > 99 ? "99+" : "\(value)"
        self.labelCount.text = "\(stringValue)"
        if let image = updateImage {
            self.updateProfileImage(profileImage: image)
        }
    }
    
    func updateProfileImage(profileImage: Any?, callback: (()->())? = nil) {
        if let imageData = profileImage as? Data {
            self.imageView.image = UIImage(data: imageData)
            callback?()
        }
        else if let profileImageString = profileImage as? String {
            if profileImageString.isEmpty {
                self.imageView.image = UIImage(named: Strings.dashboardDefaultIcon)
                callback?()
            }
            else {
                self.imageView.pinImageFromURL(URL(string: profileImageString), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon)) { (_) in
                     callback?()
                }
            }
        }
    }
}
