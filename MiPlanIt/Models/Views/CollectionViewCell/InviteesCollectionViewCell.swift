//
//  InviteesCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol InviteesCollectionViewCellDelegate: class {
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, removeCalendar onIndex: IndexPath?)
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, showInfo onIndex: IndexPath?)
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, changeAccess type: UserAccesType)
}

enum UserAccesType { case full, partial }

class InviteesCollectionViewCell: UICollectionViewCell {
    
    var index: IndexPath?
    var calenderUser: Any?
    var accessTypeCell: UserAccesType?
    weak var delegate: InviteesCollectionViewCellDelegate?
    
    @IBOutlet weak var buttonRemove: UIButton?
    @IBOutlet weak var imageViewProfilePic: UIImageView?
    @IBOutlet weak var labelUserName: UILabel?
    @IBOutlet weak var labelUserSubText: UILabel?
    @IBOutlet weak var imageViewUserStatus: UIImageView?
    @IBOutlet weak var labelEmailOrPhone: UILabel?
    @IBOutlet weak var labelOwnerName: UILabel?
    @IBOutlet weak var viewMaskImage: UIView?
    @IBOutlet weak var buttonToggleAccess: UIButton?
    @IBOutlet weak var imageViewMiPlaniT: UIImageView?
    
    override func prepareForReuse() {
        self.imageViewProfilePic?.image = nil
        self.labelUserName?.text = Strings.empty
        self.labelEmailOrPhone?.text = Strings.empty
        self.labelEmailOrPhone?.isHidden = true
        super.prepareForReuse()
    }
    
    func configureCell(otherUser: OtherUser) {
        self.labelUserName?.text = otherUser.fullName != Strings.empty ? otherUser.fullName : otherUser.email
        self.downloadUserProfileImageFromServer(otherUser)
        self.configureInviteeRespondStatus(otherUser.readResponseStatus())
        self.setLongPressGesture()
        self.labelEmailOrPhone?.isHidden = otherUser.isPrivate
        self.labelEmailOrPhone?.text = otherUser.userContainsEmailInPhoneContact ? otherUser.email : otherUser.phone
    }
    
    private func configBaseCell(calendarUser: CalendarUser?, index: IndexPath, accessType: UserAccesType? = nil, delegate: InviteesCollectionViewCellDelegate? = nil, isOwner: Bool = false) {
        self.viewMaskImage?.isHidden = calendarUser != nil
        self.index = index
        self.delegate = delegate
        self.calenderUser = calendarUser
        self.labelUserName?.text = calendarUser?.readName()
        self.buttonRemove?.isHidden = false
        self.accessTypeCell = accessType
        self.imageViewProfilePic?.image = nil
        self.downloadUserProfileImageFromServer(calendarUser)
        self.labelUserSubText?.text = Strings.empty
        self.configureInviteeRespondStatus(calendarUser?.respondStatus ?? .eDefault)
        if let user = calendarUser, user.userType != .miplanit {
            self.labelUserSubText?.text = !user.phone.isEmpty ? user.phone : user.email
        }
        self.buttonRemove?.isHidden = !(calendarUser?.isDeletable ?? true)
        self.labelOwnerName?.text = !isOwner ? Strings.empty : "(Owner)"
        self.setLongPressGesture()
        self.labelEmailOrPhone?.isHidden = (calendarUser?.email.isEmpty ?? true && calendarUser?.phone.isEmpty ?? true) || calendarUser?.isPrivate ?? false
        self.labelEmailOrPhone?.text =  calendarUser?.userContainsEmailInPhoneContact ?? false ? calendarUser?.email : calendarUser?.phone
        self.imageViewMiPlaniT?.isHidden = true
        if let user = calendarUser {
            self.imageViewMiPlaniT?.isHidden = user.userType != .miplanit
        }
    }
    
    func configureCell(calendarUser: CalendarUser?, index: IndexPath, accessType: UserAccesType? = nil, delegate: InviteesCollectionViewCellDelegate? = nil, isOwner: Bool = false) {
        self.configBaseCell(calendarUser: calendarUser, index: index, accessType: accessType, delegate: delegate, isOwner: isOwner)
        self.buttonToggleAccess?.isSelected = (calendarUser?.accessLevel ?? 2) == 2 ? true : false
    }
    
    func configureVisibilityCell(calendarUser: CalendarUser?, index: IndexPath, accessType: UserAccesType? = nil, delegate: InviteesCollectionViewCellDelegate? = nil, isOwner: Bool = false) {
        self.configBaseCell(calendarUser: calendarUser, index: index, accessType: accessType, delegate: delegate, isOwner: isOwner)
        self.buttonToggleAccess?.isSelected = (calendarUser?.visibility ?? 0) == 0 ? true : false
    }
    
    func setLongPressGesture() {
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.imageViewProfilePic?.addGestureRecognizer(longPressGR)
        self.setLongPressInButton()
    }
    
    func setLongPressInButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
        tapGesture.numberOfTapsRequired = 1
        self.buttonRemove?.addGestureRecognizer(tapGesture)
        self.buttonRemove?.addGestureRecognizer(longGesture)
    }
    
    @objc func tap() {
        self.delegate?.inviteesCollectionViewCell(self, removeCalendar: self.index)
    }

    @objc func long() {
        self.delegate?.inviteesCollectionViewCell(self, showInfo: self.index)
    }
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        self.delegate?.inviteesCollectionViewCell(self, showInfo: self.index)
    }
    
    private func configureInviteeRespondStatus(_ status: RespondStatus) {
        switch status {
        case .eAccepted:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "acceptedInvitee")
        case .eRejected:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "rejectedInvitee")
        case .eNotResponded:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "notRespondedInvitee")
        default:
            self.imageViewUserStatus?.isHidden = true
            self.imageViewUserStatus?.image = nil

        }
    }
    
    func configureCellReset() {
        self.labelUserSubText?.text = nil
        self.buttonRemove?.isHidden = true
        self.imageViewProfilePic?.image = nil
        self.calenderUser = nil
    }
    
    func configureCell(newInviteeId: String) {
        self.labelUserSubText?.text = nil
        self.calenderUser = CalendarUser(newInviteeId)
        self.labelUserName?.text = newInviteeId
        self.imageViewProfilePic?.image = newInviteeId.shortStringImage(1)
    }
    
    func downloadUserProfileImageFromServer(_ calenderUser: Any?) {
        var profileImage: String = ""; var placeHolder: UIImage?
        if let otherUser = calenderUser as? OtherUser {
            placeHolder = (otherUser.fullName.isEmpty ? (otherUser.email) : otherUser.fullName ).shortStringImage(1)
            profileImage = otherUser.profileImage
        }
        else if let planItInvitees = calenderUser as? PlanItInvitees {
            placeHolder = ((planItInvitees.fullName ?? Strings.empty).isEmpty ? planItInvitees.email : planItInvitees.fullName)?.shortStringImage(1)
            profileImage = planItInvitees.profileImage ?? Strings.empty
        }
        else if let calendarUser = calenderUser as? CalendarUser {
            placeHolder = (calendarUser.name.isEmpty ? calendarUser.email : calendarUser.name).shortStringImage(1)
            profileImage = calendarUser.profile 
        }
        self.imageViewProfilePic?.pinImageFromURL(URL(string: profileImage), placeholderImage: placeHolder)
    }
    
    @IBAction func toggleAccessClicked(_ sender: UIButton) {
        self.delegate?.inviteesCollectionViewCell(self, changeAccess: sender.isSelected ? .partial : .full)
    }
    
    
    @IBAction func removeButtonClicked(_ sender: UIButton) {
        self.delegate?.inviteesCollectionViewCell(self, removeCalendar: self.index)
    }
}
