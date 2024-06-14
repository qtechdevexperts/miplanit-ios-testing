//
//  SharedViewController+Collection.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension SharedViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedInvitees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewAllUser.frame.width, height: 60.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        if let inviteesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.userImageCell, for: indexPath) as? InviteesCollectionViewCell {
            cell = inviteesCollectionViewCell
            inviteesCollectionViewCell.configureCell(calendarUser: self.selectedInvitees[indexPath.row], index: indexPath, delegate: nil, isOwner: self.selectedInvitees[indexPath.row].userId == self.categoryOwnerId)
        }
        return cell
    }
}
