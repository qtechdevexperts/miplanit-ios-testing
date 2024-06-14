//
//  DatabasePlanItEventAttachment.swift
//  MiPlanIt
//
//  Created by Arun on 17/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItEventAttachment: DataBaseManager {
    
    func insertAttachments(_ attachments: [PlanItEventAttachment], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllAttachments()
        let objectContext = context ?? self.mainObjectContext
        for eachAttachments in attachments {
            let attachmentsEntity = self.insertNewRecords(Table.planItEventAttachment, context: objectContext) as! PlanItEventAttachment
            attachmentsEntity.fileUrl = eachAttachments.fileUrl
            attachmentsEntity.title = eachAttachments.title
            attachmentsEntity.iconLink = eachAttachments.iconLink
            attachmentsEntity.event = event
        }
    }
    
    func insertAttachments(_ attachments: [[String: Any]], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllAttachments()
        let objectContext = context ?? self.mainObjectContext
        for eachAttachments in attachments {
            let attachmentsEntity = self.insertNewRecords(Table.planItEventAttachment, context: objectContext) as! PlanItEventAttachment
            attachmentsEntity.fileUrl = eachAttachments["fileUrl"] as? String
            attachmentsEntity.title = eachAttachments["title"] as? String
            attachmentsEntity.iconLink = eachAttachments["iconLink"] as? String
            attachmentsEntity.event = event
        }
    }
}
