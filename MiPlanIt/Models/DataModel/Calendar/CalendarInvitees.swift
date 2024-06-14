//
//  CalendarInvitees.swift
//  MiPlanIt
//
//  Created by Arun on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Contacts

class CalendarInvitees {
    
    var endBlock: ()->()
    var name: String = Strings.empty
    var allUsers: [CalendarUser] = []
    var selectedUsers: [CalendarUser] = []
    var fullAccesUsers: [CalendarUser] = []
    var partailAccesUsers: [CalendarUser] = []
    
    var sortedFullPartialUsers: [CalendarUser] {
        get {
            return (fullAccesUsers+partailAccesUsers).sorted{ (user1, user2) -> Bool in
                if user1.readName() == user2.readName() {
                    return user1.readEmailOrPhone() < user2.readEmailOrPhone()
                }
                return user1.readName() < user2.readName()
            }
        }
    }
    
    init(start: @escaping ()->(), end: @escaping ()->()) {
        self.endBlock = end
        NotificationCenter.default.addObserver(self, selector: #selector(contactFetchedConpleted), name: NSNotification.Name(rawValue: Notifications.fetehUserContactProcessFinished), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.readAllUsers(start: start)
        }
    }
    
    func readAllUsers(start: ()->()) {
        start()
        if !Session.shared.isAllContactUserFetching && !Session.shared.isAllDatabaseUserFetching {
            self.allUsers = Session.shared.readFullContacts()
            self.endBlock()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.fetehUserContactProcessFinished), object: nil)
    }
    
    @objc func contactFetchedConpleted(_ notify: Notification) {
        self.allUsers = Session.shared.readFullContacts()
        self.endBlock()
    }
    
    func insertNewUser(_ user: CalendarUser, toFullAcess: Bool = false, toPartialAcess: Bool = false) {
        if toFullAcess {
            user.accessLevel = 2
            self.fullAccesUsers.append(user)
        }
        else if toPartialAcess {
            user.accessLevel = 1
            self.partailAccesUsers.append(user)
        }
        else {
            self.selectedUsers.insert(user, at: self.selectedUsers.count)
        }
    }
    
    func insertNewVisibilityUser(_ user: CalendarUser, visible: Bool = false, nonVisible: Bool = false) {
        if visible {
            user.visibility = 0
            self.fullAccesUsers.append(user)
        }
        else if nonVisible {
            user.visibility = 1
            self.partailAccesUsers.append(user)
        }
        else {
            self.selectedUsers.insert(user, at: self.selectedUsers.count)
        }
    }
}
