//
//  PlanItInvitees+Save.swift
//  MiPlanIt
//
//  Created by Arun on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItInvitees {
    func readValueOfUserName() -> String { return self.userName ?? Strings.empty }
    func readValueOfEmail() -> String { return self.email ?? Strings.empty }
    func readValueOfFullName() -> String { return self.fullName ?? Strings.empty }
    func readValueOfPhone() -> String { return self.phone ?? Strings.empty }
    func readValueOfCountryCode() -> String { return self.countryCode ?? Strings.empty }
    func readValueOfProfileImage() -> String { return self.profileImage ?? Strings.empty }
    func readValueOfUserId() -> String { return self.userId == 0 ? Strings.empty : self.userId.cleanValue() }
    func readValueOfSharedStatus() -> Double { return self.sharedStatus }
    func readValueOfCreatedByUserId() -> String { return self.createdBy?.readValueOfUserId() ?? Strings.empty }
    func readValueOfVisibility() -> Double { return self.accessLevel }
    
    func readResponseStatus() -> RespondStatus {
        switch self.sharedStatus {
        case 0:
            return .eNotResponded
        case 1:
            return .eAccepted
        case 2:
            return .eRejected
        default:
            return .eNotResponded
        }
    }
    
    func deleteSharedUser(withHardSave status: Bool = true) {
        guard let deletedSharedUser = self.sharedBy else { return }
        self.sharedBy = nil
        deletedSharedUser.deleteItSelf(withHardSave: status)
    }
    
    func deleteCreatedByUser(withHardSave status: Bool = true) {
        guard let createdBy = self.createdBy else { return }
        self.createdBy = nil
        createdBy.deleteItSelf(withHardSave: status)
    }
}
