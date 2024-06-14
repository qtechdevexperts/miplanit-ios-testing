//
//  DataBaseManager.swift
//  MiPlanIt
//
//  Created by Arun on 13/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DataBaseManager {
    
    func readRecords(fromCoreData tableName: String, predicate: NSPredicate? = nil, sortDescriptor: [String]? = nil, ascending: Bool = true, limit: Int = 0, context: NSManagedObjectContext) -> [Any] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: tableName, in: context)
        fetchRequest.entity = entity
        fetchRequest.returnsObjectsAsFaults = false
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        if let sortkeys = sortDescriptor {
            var sortedItems: [NSSortDescriptor] = []
            for key in sortkeys {
                let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
                sortedItems.append(sortDescriptor)
            }
            fetchRequest.sortDescriptors = sortedItems
        }
        if limit != 0 {
            fetchRequest.fetchLimit = limit
        }
        do {
            let records: [Any] = try context.fetch(fetchRequest)
            return records
        } catch  {
            assert(true, error.localizedDescription)
        }
        return []
    }
    
    func insertNewRecords(_ tableName: String, context: NSManagedObjectContext) -> Any? {
        let table: Any? = NSEntityDescription.insertNewObject(forEntityName: tableName, into:  context)
        return table
    }
    
    lazy var mainObjectContext: NSManagedObjectContext = {
        return CoreData.default.mainManagedObjectContext
    }()
    
    lazy var privateObjectContext: PrivateManagedObjectContext = {
        let context = PrivateManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainObjectContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
}
