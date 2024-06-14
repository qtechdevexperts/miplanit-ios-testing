//
//  PlanItCreator+Save.swift
//  MiPlanIt
//
//  Created by Arun on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItCreator {
    func readValueOfUserName() -> String { return self.userName ?? Strings.empty }
    func readValueOfEmail() -> String { return self.email ?? Strings.empty }
    func readValueOfFullName() -> String {
        if self.readValueOfUserId() == Session.shared.readUserId() {
            return Session.shared.readUser()?.readValueOfName() ?? Strings.empty
        }
        else {
            return self.fullName ?? Strings.empty
        }
    }
    func readValueOfPhone() -> String { return self.phone ?? Strings.empty }
    func readValueOfProfileImage() -> String { return self.profileImage ?? Strings.empty }
    func readValueOfUserId() -> String { return self.userId == 0 ? Strings.empty : self.userId.cleanValue() }
    
    func deleteItSelf(withHardSave status: Bool = true) {
        self.managedObjectContext?.delete(self)
        if status { try? self.managedObjectContext?.save() }
    }
}
