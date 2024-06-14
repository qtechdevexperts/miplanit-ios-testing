//
//  UsersCalendarViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class UserSelectionBaseViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel?
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var labelTableHeader: UILabel!
    @IBOutlet weak var buttonCloseSearch: UIButton!
    @IBOutlet weak var textFieldSearchUser: FloatingTextField!
    @IBOutlet weak var tableheaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewAllUser: UICollectionView!
    @IBOutlet weak var collectionViewSelectedUser: UICollectionView!
    @IBOutlet weak var labelSuggustedUser: UILabel!
    @IBOutlet weak var viewLabelSuggustedUser: UIView?
    @IBOutlet weak var labelNoUserSelected: UILabel?
    
    var inviteesDragView: InviteesDragView!
    
    lazy var calenderUsers: CalendarInvitees = {
        return CalendarInvitees(start: {
            self.startContactFetching()
        }, end: {
            self.stopContactFetching()
            self.refreshUsersView()
        })
    }()

    var filteredUsers: [CalendarUser] = [] {
        didSet {
            self.sectionedUser.removeAll()
            let miPlanItUsers = filteredUsers.filter({ return $0.userType == .miplanit })
            let otherUsers = filteredUsers.filter({ return $0.userType != .miplanit })
            self.sectionedUser.append(miPlanItUsers)
            self.sectionedUser.append(otherUsers)
        }
    }
    
    var sectionedUser: [[CalendarUser]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponent()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    @IBAction func textFieldDidChangeText(_ sender: FloatingTextField) {
        self.searchUsersListWithText(sender.text)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: UIButton) {
        self.textFieldSearchUser.text = Strings.empty
        self.searchUsersListWithText(self.textFieldSearchUser.text)
    }
    
    @IBAction func closeUserSelectionButtonClicked(_ sender: UIButton) {
        self.closeUserSelection()
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.sendSelectedUsers(self.calenderUsers.selectedUsers)
    }
    
    //MARK: - Override Methods
    func closeUserSelection() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func readPageTitle() -> String? {
        return ""
    }
    
    func readTableTitle() -> String? {
        return ""
    }
    
    func readPlaceHolder() -> String? {
        return ""
    }
    
    func startContactFetching() {
        //textfield disable
        //start animation
    }
    
    func stopContactFetching() {
        //textfield enable
        //stop animation
    }
    
    func showSelectionUserInfo(_ user: InviteesCollectionViewCell) {
        
    }
    
    func sendSelectedUsers(_ options: [CalendarUser]) { }
}

