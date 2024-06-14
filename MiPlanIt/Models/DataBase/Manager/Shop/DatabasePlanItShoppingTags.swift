//
//  DatabasePlanItShoppingTags.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItSuggustionTags: DataBaseManager {
    
    func insertShoppingTags(_ tags: [String], of type: SourceScreen, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localTags = self.readAllTags(of: type, using: context)
        for eachTags in tags {
            let tagEntity = localTags.filter({ return $0.tag?.lowercased() == eachTags.lowercased() }).first ?? self.insertNewRecords(Table.planItSuggustionTags, context: objectContext) as! PlanItSuggustionTags
            tagEntity.tag = eachTags
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.type = Int16(type.rawValue)
        }
        self.mainObjectContext.saveContext()
    }
    
    func readAllTags(of type: SourceScreen, using context: NSManagedObjectContext? = nil) -> [PlanItSuggustionTags] {
         let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ && type == %i", Session.shared.readUserId(), type.rawValue)
        return self.readRecords(fromCoreData: Table.planItSuggustionTags, predicate: predicate, context: objectContext) as! [PlanItSuggustionTags]
    }
}
