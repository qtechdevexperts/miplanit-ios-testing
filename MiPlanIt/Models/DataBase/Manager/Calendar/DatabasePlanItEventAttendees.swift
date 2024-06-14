//
//  DatabasePlanItEventAttendees.swift
//  MiPlanIt
//
//  Created by Arun on 17/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItEventAttendees: DataBaseManager {
    
    func insertAttendees(_ attendees: [PlanItEventAttendees], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllAttendees()
        let objectContext = context ?? self.mainObjectContext
        for eachAttendees in attendees {
            let attendeesEntity = self.insertNewRecords(Table.planItEventAttendees, context: objectContext) as! PlanItEventAttendees
            attendeesEntity.email = eachAttendees.email
            attendeesEntity.name = eachAttendees.name
            attendeesEntity.status = eachAttendees.status
            attendeesEntity.event = event
        }
    }

    func insertAttendees(_ attendees: [[String: Any]], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllAttendees()
        let objectContext = context ?? self.mainObjectContext
        for eachAttendees in attendees {
            let attendeesEntity = self.insertNewRecords(Table.planItEventAttendees, context: objectContext) as! PlanItEventAttendees
            attendeesEntity.email = eachAttendees["email"] as? String
            attendeesEntity.name = eachAttendees["name"] as? String
            attendeesEntity.status = eachAttendees["status"] as? String
            attendeesEntity.event = event
        }
    }
}
