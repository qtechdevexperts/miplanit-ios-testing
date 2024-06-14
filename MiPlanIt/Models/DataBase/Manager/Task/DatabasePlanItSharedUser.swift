//
//  DatabasePlanItSharedUser.swift
//  MiPlanIt
//
//  Created by Arun on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItSharedUser: DataBaseManager {
    
    func insertInvitees(_ invitee: PlanItInvitees, shared user: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let sharedUserEntity = invitee.sharedBy ?? self.insertNewRecords(Table.planItSharedUser, context: objectContext) as! PlanItSharedUser
        sharedUserEntity.userId = user["userId"] as? Double ?? 0
        sharedUserEntity.userName = user["userName"] as? String
        sharedUserEntity.fullName = user["fullName"] as? String
        sharedUserEntity.phone = user["phone"] as? String
        sharedUserEntity.email = user["email"] as? String
        sharedUserEntity.profileImage = user["profileImage"] as? String
        sharedUserEntity.origin = Session.shared.readUserId()
        sharedUserEntity.invitee = invitee
    }
}
