//
//  PlanItContacts+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension PlanItContacts {
    
    func readName() -> String { return self.userName ?? Strings.empty }
    func readUserId() -> String { return self.userId == 0 ? Strings.empty : self.userId.cleanValue() }
    func readProfileImage() -> String { return self.profileImage ?? Strings.empty }
    func readEmail() -> String { return self.email ?? Strings.empty }
    func readPhone() -> String { return self.phone ?? Strings.empty }
    func readCountryCode() -> String { return self.telCountryCode ?? Strings.empty }
    func readUserEmailExistInContact() -> Bool { return self.isEmailExistInContact }
    func readUserPhoneExistInContact() -> Bool { return self.isPhoneExistInContact }
}
