//
//  DatabasePlanItInvitees.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItInvitees: DataBaseManager {
    
    func insertCalendar(_ calendar: PlanItCalendar, invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = invitee["userId"] as? Double ?? 0
            inviteeEntity.accessLevel = invitee["accessLevel"] as? Double ?? 1
            inviteeEntity.userName = invitee["userName"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.profileImage = invitee["profileImage"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.isNotifyCalendar = invitee["isNotifyCalendar"] as? Bool ?? false
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.calendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertCalendar(_ calendar: PlanItCalendar, other invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.calendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertCalendar(_ calendar: PlanItCalendar, invitees: NewCalendar, using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees.fullAccesUsers {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.accessLevel = 2
            inviteeEntity.userName = invitee.name
            inviteeEntity.fullName = invitee.name
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profile
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.isNotifyCalendar = false
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.calendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
        for invitee in invitees.partailAccesUsers {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.accessLevel = 1
            inviteeEntity.userName = invitee.name
            inviteeEntity.fullName = invitee.name
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profile
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.isNotifyCalendar = false
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.calendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
        
        for invitee in invitees.notifyUsers {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.accessLevel = 1
            inviteeEntity.userName = invitee.name
            inviteeEntity.fullName = invitee.name
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profile
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.isNotifyCalendar = true
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.calendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShareBaseCalendar(_ calendar: PlanItCalendar, sharedUser: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllSharedUser()
        let objectContext = context ?? self.mainObjectContext
        for user in sharedUser {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = user["userId"] as? Double ?? 0
            inviteeEntity.isOther = false
            inviteeEntity.accessLevel = user["accessLevel"] as? Double ?? 1
            inviteeEntity.accessLevel = user["visibility"] as? Double ?? 1
            inviteeEntity.userName = user["userName"] as? String
            inviteeEntity.fullName = user["fullName"] as? String
            inviteeEntity.phone = user["phone"] as? String
            inviteeEntity.email = user["email"] as? String
            inviteeEntity.countryCode = user["telCountryCode"] as? String
            inviteeEntity.profileImage = user["profileImage"] as? String
            inviteeEntity.sharedStatus = user["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.sharedBaseCalendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShareBaseCalendar(_ calendar: PlanItCalendar, other users: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllExternalSharedUser()
        let objectContext = context ?? self.mainObjectContext
        for user in users {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.fullName = user["fullName"] as? String
            inviteeEntity.phone = user["phone"] as? String
            inviteeEntity.email = user["email"] as? String
            inviteeEntity.countryCode = user["telCountryCode"] as? String
            inviteeEntity.sharedStatus = user["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.sharedBaseCalendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertCalendar(_ calendar: PlanItCalendar, invitees: CalendarInvitees, using context: NSManagedObjectContext? = nil) {
        calendar.deleteAllSharedUser()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees.fullAccesUsers {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.accessLevel = 0
            inviteeEntity.userName = invitee.name
            inviteeEntity.fullName = invitee.name
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profile
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.sharedBaseCalendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
        for invitee in invitees.partailAccesUsers {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.accessLevel = 1
            inviteeEntity.userName = invitee.name
            inviteeEntity.fullName = invitee.name
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profile
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.sharedBaseCalendar = calendar
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertEvent(_ event: PlanItEvent, main invitees: [PlanItInvitees], using context: NSManagedObjectContext? = nil) {
        event.deleteAllInternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = false
            inviteeEntity.userId = invitee.userId
            inviteeEntity.accessLevel = invitee.accessLevel
            inviteeEntity.userName = invitee.userName
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.profileImage = invitee.profileImage
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.event = event
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertEvent(_ event: PlanItEvent, main invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        event.deleteAllInternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = false
            inviteeEntity.userId = invitee["userId"] as? Double ?? 0
            inviteeEntity.accessLevel = invitee["accessLevel"] as? Double ?? 1
            inviteeEntity.userName = invitee["userName"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.profileImage = invitee["profileImage"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.event = event
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertEvent(_ event: PlanItEvent, other invitees: [PlanItInvitees], using context: NSManagedObjectContext? = nil) {
        event.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.event = event
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertEvent(_ event: PlanItEvent, other invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        event.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.event = event
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertEvent(_ event: PlanItEvent, other invitees: [OtherUser], using context: NSManagedObjectContext? = nil) {
        event.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.profileImage = invitee.profileImage
            inviteeEntity.event = event
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertTodo(_ todo: PlanItTodo, main invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        todo.deleteAllInternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = false
            inviteeEntity.userId = invitee["userId"] as? Double ?? 0
            inviteeEntity.accessLevel = invitee["accessLevel"] as? Double ?? 1
            inviteeEntity.userName = invitee["userName"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.isRead = invitee["isRead"] as? Bool ?? true
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.profileImage = invitee["profileImage"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            if let createdBy = invitee["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertCreatedInvitees(inviteeEntity, todo: todo, creator: createdBy, using: objectContext)
            }
            else {
                inviteeEntity.deleteCreatedByUser(withHardSave: false)
            }
            inviteeEntity.origin = Session.shared.readUserId()
            if inviteeEntity.readValueOfUserId() == inviteeEntity.origin {
                todo.isAssignedToMe = true
                todo.isAssignedToMeAccepted = inviteeEntity.sharedStatus == 1
            }
            inviteeEntity.todo = todo
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertTodo(_ todo: PlanItTodo, other invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        todo.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.todo = todo
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertTodo(_ todo: PlanItTodo, other invitee: CalendarUser, using context: NSManagedObjectContext? = nil) {
        todo.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
        inviteeEntity.isOther = true
        inviteeEntity.phone = invitee.phone
        inviteeEntity.email = invitee.email
        inviteeEntity.fullName = invitee.name
        inviteeEntity.countryCode = invitee.countryCode
        inviteeEntity.origin = Session.shared.readUserId()
        inviteeEntity.userId = Double(invitee.userId) ?? 0
        if inviteeEntity.readValueOfUserId() == inviteeEntity.origin {
            todo.isAssignedToMe = true
            todo.isAssignedToMeAccepted = inviteeEntity.sharedStatus == 1
        }
        inviteeEntity.todo = todo
        inviteeEntity.profileImage = invitee.profile
        Session.shared.insertDBUser(inviteeEntity)
    }
    
    func insertTodo(_ todo: PlanItTodo, other invitees: [OtherUser], using context: NSManagedObjectContext? = nil) {
        todo.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.profileImage = invitee.profileImage
            if inviteeEntity.readValueOfUserId() == inviteeEntity.origin {
                todo.isAssignedToMe = true
                todo.isAssignedToMeAccepted = inviteeEntity.sharedStatus == 1
            }
            inviteeEntity.todo = todo
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShop(_ shop: PlanItShopList, other invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        shop.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.shop = shop
            if let sharedBy = invitee["createdBy"] as? [String: Any] {
                DatabasePlanItSharedUser().insertInvitees(inviteeEntity, shared: sharedBy, using: objectContext)
            }
            else {
                inviteeEntity.deleteSharedUser(withHardSave: false)
            }
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShop(_ shop: PlanItShopList, invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        shop.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.userId = invitee["userId"] as? Double ?? 0
            inviteeEntity.accessLevel = invitee["accessLevel"] as? Double ?? 1
            inviteeEntity.userName = invitee["userName"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.profileImage = invitee["profileImage"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.shop = shop
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShop(_ shop: PlanItShopList, invitees: [OtherUser], using context: NSManagedObjectContext? = nil) {
        shop.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.profileImage = invitee.profileImage
            inviteeEntity.userName = invitee.userName
            inviteeEntity.sharedStatus = invitee.sharedStatus
            inviteeEntity.shop = shop
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertToDoCategory(_ toDoCategory: PlanItTodoCategory, main invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        toDoCategory.deleteAllInternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = false
            inviteeEntity.userId = invitee["userId"] as? Double ?? 0
            inviteeEntity.accessLevel = invitee["accessLevel"] as? Double ?? 1
            inviteeEntity.userName = invitee["userName"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.profileImage = invitee["profileImage"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.todoCategory = toDoCategory
            if let sharedBy = invitee["createdBy"] as? [String: Any] {
                DatabasePlanItSharedUser().insertInvitees(inviteeEntity, shared: sharedBy, using: objectContext)
            }
            else {
                inviteeEntity.deleteSharedUser(withHardSave: false)
            }
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertToDoCategory(_ toDoCategory: PlanItTodoCategory, other invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        toDoCategory.deleteAllExternalInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee["phone"] as? String
            inviteeEntity.email = invitee["email"] as? String
            inviteeEntity.fullName = invitee["fullName"] as? String
            inviteeEntity.countryCode = invitee["telCountryCode"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.todoCategory = toDoCategory
            if let sharedBy = invitee["createdBy"] as? [String: Any] {
                DatabasePlanItSharedUser().insertInvitees(inviteeEntity, shared: sharedBy, using: objectContext)
            }
            else {
                inviteeEntity.deleteSharedUser(withHardSave: false)
            }
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertToDoCategory(_ toDoCategory: PlanItTodoCategory, other invitees: [OtherUser], using context: NSManagedObjectContext? = nil) {
        toDoCategory.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.todoCategory = toDoCategory
            inviteeEntity.profileImage = invitee.profileImage
            Session.shared.insertDBUser(inviteeEntity)
        }
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, invitees: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.email = invitee["sharedEmail"] as? String
            inviteeEntity.sharedStatus = invitee["sharedStatus"] as? Double ?? 0
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.shareLink = shareLink
        }
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, other invitees: [OtherUser], using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllInvitees()
        let objectContext = context ?? self.mainObjectContext
        for invitee in invitees {
            let inviteeEntity = self.insertNewRecords(Table.planItInvitees, context: objectContext) as! PlanItInvitees
            inviteeEntity.isOther = true
            inviteeEntity.phone = invitee.phone
            inviteeEntity.email = invitee.email
            inviteeEntity.fullName = invitee.fullName
            inviteeEntity.countryCode = invitee.countryCode
            inviteeEntity.origin = Session.shared.readUserId()
            inviteeEntity.userId = Double(invitee.userId) ?? 0
            inviteeEntity.profileImage = invitee.profileImage
            inviteeEntity.shareLink = shareLink
        }
    }
    
    func readAllUserInvitees(using context: NSManagedObjectContext? = nil) -> [PlanItInvitees] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "origin == %@ AND userId <> %@ AND isOther == NO", Session.shared.readUserId(), Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItInvitees, predicate: predicate, context: objectContext) as! [PlanItInvitees]
    }
}
