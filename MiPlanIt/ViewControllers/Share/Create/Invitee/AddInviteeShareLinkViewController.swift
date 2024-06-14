//
//  AddInviteeShareLinkViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol AddInviteeShareLinkViewControllerDelegate: AnyObject {
    func addInviteeShareLinkViewController(_ addInviteeShareLinkViewController: AddInviteeShareLinkViewController, selectedAssige: CalendarUser?)
}

class AddInviteeShareLinkViewController: AssignToDoViewController {

    weak var addInviteeShareLinkDelegate: AddInviteeShareLinkViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    
    
    override func refreshUsersView(index: IndexPath? = nil, whileRemoving: Bool = false) {
        let allBalanceUsers = self.readAllBalanceUsers().filter({ !$0.email.isEmpty && $0.userType != .miplanit })
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            self.filteredUsers = allBalanceUsers.filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil }).map({ AssignUser(calendarUser: $0) })
        }
        else {
            self.filteredUsers = allBalanceUsers.map({ AssignUser(calendarUser: $0) })
            self.sectionedUser.append(allBalanceUsers.map({ AssignUser(calendarUser: $0) }))
        }
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.assignUserHeaderView, for: indexPath) as! AssignUserHeaderView
            reusableview.labelHeader.text = Strings.otherUsers
            return reusableview
        default: return UICollectionReusableView()
        }
    }
    
    override func searchUsersListWithText(_ text: String?) {
        let searchText = text ?? Strings.empty
        self.labelSuggustedUser.isHidden = !searchText.isEmpty
        let allBalanceUsers = self.readAllBalanceUsers().filter({ !$0.email.isEmpty && $0.userType != .miplanit })
        if searchText.isEmpty {
            self.filteredUsers = allBalanceUsers.map({ AssignUser(calendarUser: $0) })
        }
        else {
            self.filteredUsers = allBalanceUsers.filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil }).map({ AssignUser(calendarUser: $0) })
        }
        self.viewNewEmail.isHidden = !(self.filteredUsers.isEmpty && searchText.validateEmail())
        if self.filteredUsers.isEmpty && searchText.validateEmail() {
            self.labelNewEmail.text = searchText
        }
        self.collectionView?.reloadData()
    }
    
    override func createServiceToCheckEmailNotExist(_ username: String?, completion: @escaping (Bool, String?)->()) {
        guard let email = username else { completion(false, Message.unknownError); return  }
        if !SocialManager.default.isNetworkReachable() { completion(true, nil); return }
        self.buttonDone?.startAnimation()
        UserService().checkUserAlreadyExist(email) { (status, error) in
            self.buttonDone?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                if let result = status, result {
                    completion(true, nil)
                }
                else {
                    completion(false, Message.userAlreadyExistInMiPlaniT)
                }
            }
        }
    }

}


extension AddInviteeShareLinkViewController: AssignToDoViewControllerDelegate {
    
    func assignToDoViewController(_ assignToDoViewController: AssignToDoViewController, selectedAssige: CalendarUser?, toDoItems: [PlanItTodo]) {
        self.addInviteeShareLinkDelegate?.addInviteeShareLinkViewController(self, selectedAssige: selectedAssige)
    }
}
