//
//  ViewDetailsInvitees.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsInvitees: UIView {
    
    @IBOutlet weak var collectionViewInvitees: UICollectionView!
    @IBOutlet weak var constraintCollectionViewInviteesHeight: NSLayoutConstraint!
    
    var invitees: [OtherUser] = [] {
        didSet {
            self.collectionViewInvitees.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialiseTagCollectionFlowLayout()
    }
    
    func initialiseTagCollectionFlowLayout() {
        self.collectionViewInvitees.dataSource = self
        self.collectionViewInvitees.delegate = self
    }
    
    func setInvitees(_ otherUser: [OtherUser]) {
        self.invitees = otherUser
        self.isHidden = self.invitees.isEmpty
        self.constraintCollectionViewInviteesHeight.constant = CGFloat(self.invitees.count*(40+18))
    }
}


extension ViewDetailsInvitees: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.invitees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inviteesCollectionViewCell", for: indexPath) as! InviteesCollectionViewCell
        cell.configureCell(otherUser: self.invitees[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewInvitees.frame.width, height: 40.0)
    }
}
