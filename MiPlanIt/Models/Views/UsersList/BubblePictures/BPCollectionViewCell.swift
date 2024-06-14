//
//  BPCollectionViewCell.swift
//  Pods
//
//  Created by Kevin Belter on 1/2/17.
//
//

import UIKit

final class BPCollectionViewCell: UICollectionViewCell {
    
    class var className: String { return "BPCollectionViewCell" }
    
    @IBOutlet weak var viewWhiteBorders: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewBackgroundWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNameCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var imgAcceptStatus: UIImageView!
    @IBOutlet weak var viewCalendarColor: UIView!
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()

        viewWhiteBorders.layer.masksToBounds = true
        viewWhiteBorders.layer.cornerRadius = viewWhiteBorders.bounds.height / 2.0

        imgBackground.layer.masksToBounds = true
        imgBackground.layer.cornerRadius = imgBackground.bounds.height / 2.0

        viewBackground.layer.masksToBounds = true
        viewBackground.layer.cornerRadius = viewBackground.bounds.height / 2.0
    }
    
    func configure(configFile: BPCellConfigFile, layoutConfigurator: BPLayoutConfigurator, isTruncatedCell: Bool) {
        self.backgroundColor = UIColor.clear
        
        viewBackground.isHidden = true
        configureImage(configFile: configFile, layoutConfigurator: layoutConfigurator, isTruncatedCell: isTruncatedCell)
        configureTitle(fullTitle: configFile.title, maxLenght: layoutConfigurator.maxCharactersForBubbleTitles, isTruncatedCell: isTruncatedCell)
        configureLayout(layoutConfigurator: layoutConfigurator)
        configureCellStatus(configFile.status)
        configureInviteeRespondStatus(configFile.respondStatus)
        configureCalendarColor(configFile.eventColor)
        self.viewStatus.isHidden = isTruncatedCell
        self.imgBackground.isHidden = isTruncatedCell
        viewWhiteBorders.layer.borderWidth = layoutConfigurator.widthForBubbleBorders
        viewBackgroundWidthConstraint.constant = layoutConfigurator.widthForBubbleBorders * -2
        var nameCenterXConstant: CGFloat = -4
        if isTruncatedCell {
            switch layoutConfigurator.displayForTruncatedCell {
            case .none, .some(.number):
                nameCenterXConstant = -2
            case .some(.image), .some(.text):
                nameCenterXConstant = 0
            }
        }
        lblNameCenterXConstraint.constant = nameCenterXConstant
    }
    
    private func configureCellStatus(_ status: UserStatus) {
        switch status {
        case .eAway:
            self.viewStatus.backgroundColor = UIColor.orange
        case .eBusy:
            self.viewStatus.backgroundColor = UIColor.red
        case .eAvailable:
            self.viewStatus.backgroundColor = UIColor.green
        default:
            self.viewStatus.backgroundColor = UIColor.clear

        }
    }
    
    private func configureCalendarColor(_ color: String?) {
        if let calendarColor = color {
            self.viewCalendarColor.isHidden = false
            self.viewCalendarColor.backgroundColor = Storage().readCalendarColorFromCode(calendarColor)
        }
        else {
            self.viewCalendarColor.isHidden = true
        }
    }
    
    private func configureInviteeRespondStatus(_ status: RespondStatus) {
        switch status {
        case .eAccepted:
            self.imgAcceptStatus.isHidden = false
            self.imgAcceptStatus.image = #imageLiteral(resourceName: "acceptedInvitee")
        case .eRejected:
            self.imgAcceptStatus.isHidden = false
            self.imgAcceptStatus.image = #imageLiteral(resourceName: "rejectedInvitee")
        case .eNotResponded:
            self.imgAcceptStatus.isHidden = false
            self.imgAcceptStatus.image = #imageLiteral(resourceName: "notRespondedInvitee")
        default:
            self.imgAcceptStatus.isHidden = true
            self.imgAcceptStatus.image = nil

        }
    }
    
    
    private func configureImage(configFile: BPCellConfigFile, layoutConfigurator: BPLayoutConfigurator, isTruncatedCell: Bool) {
        switch configFile.imageType {
        case .color(let color)?:
            self.imgBackground.image = UIImage(color: color)
            self.imgBackground.backgroundColor = .white
            break
        case .image(let img)?:
            self.imgBackground.image = img
            self.imgBackground.backgroundColor = .white
            break
        default:
            self.imgBackground.backgroundColor = .clear
            self.downloadUserProfileImageFromServer(configFile)
        }
        imgBackground.contentMode = layoutConfigurator.bubbleImageContentMode
    }
    
    private func configureLayout(layoutConfigurator: BPLayoutConfigurator) {
        viewWhiteBorders.layer.borderColor = layoutConfigurator.colorForBubbleBorders.cgColor
        lblName.font = layoutConfigurator.fontForBubbleTitles
        lblName.textColor = layoutConfigurator.colorForBubbleTitles
    }
    
    private func configureTitle(fullTitle: String, maxLenght: Int, isTruncatedCell: Bool) {
        var name = ""
        defer { lblName.text = name }
        
        if isTruncatedCell {
            name = fullTitle
            return
        }
        
        let names = fullTitle.components(separatedBy: " ")
        
        if names.count == 1 {
            guard let uniqueName = names.first?.substring(to: maxLenght) else { return }
            name = uniqueName
            return
        }
        
        for (index, truncatedName) in names.enumerated() {
            if index == maxLenght { return }
            
            name = "\(name + truncatedName.substring(to: 1))"
        }
    }
    
    func downloadUserProfileImageFromServer(_ configFile: BPCellConfigFile) {
        self.imgBackground.pinImageFromURL(URL(string: configFile.imageUrl), placeholderImage: configFile.name.shortStringImage())
    }
}
