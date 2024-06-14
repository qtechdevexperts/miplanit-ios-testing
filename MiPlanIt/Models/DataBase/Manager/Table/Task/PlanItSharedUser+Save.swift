//
//  PlanItSharedUser+Save.swift
//  MiPlanIt
//
//  Created by Arun on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItSharedUser {
    func readValueOfUserName() -> String { return self.userName ?? Strings.empty }
    func readValueOfEmail() -> String { return self.email ?? Strings.empty }
    func readValueOfFullName() -> String { return self.fullName ?? Strings.empty }
    func readValueOfPhone() -> String { return self.phone ?? Strings.empty }
    func readValueOfProfileImage() -> String { return self.profileImage ?? Strings.empty }
    func readValueOfUserId() -> String { return self.userId == 0 ? Strings.empty : self.userId.cleanValue() }
    
    func deleteItSelf(withHardSave status: Bool = true) {
        self.managedObjectContext?.delete(self)
        if status { try? self.managedObjectContext?.save() }
    }
}
