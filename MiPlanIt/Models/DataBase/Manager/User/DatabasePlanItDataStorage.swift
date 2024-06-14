//
//  DatabasePlanItDataStorage.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


import Foundation
import CoreData

class DatabasePlanItDataStorage: DataBaseManager {
    
    func insertUserStorageData(_ storageData: [String: Any], callback: @escaping (Bool)->()) {
        var totalSpace: Double = 0.0
        var usedSpace: Double = 0.0
        self.privateObjectContext.perform {
            let usersDataStorage = self.readUsersDataStorage(using: self.privateObjectContext)
            let newUsersDataStorage = usersDataStorage.first ?? self.insertNewRecords(Table.planItDataStorage, context: self.privateObjectContext) as! PlanItDataStorage
            newUsersDataStorage.totalSpace = storageData["maxDataSize"] as? Double ?? 0.0
            newUsersDataStorage.usedSpace = storageData["userDataSize"] as? Double ?? 0.0
            newUsersDataStorage.user = Session.shared.readUserId()
            totalSpace = newUsersDataStorage.totalSpace
            usedSpace = newUsersDataStorage.usedSpace
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                callback(totalSpace <= usedSpace)
            }
        }
    }

    func insertUserStorageData(_ storageData: [String: Any]) -> PlanItDataStorage {
        let usersDataStorage = self.readUsersDataStorage()
        let newUsersDataStorage = usersDataStorage.first ?? self.insertNewRecords(Table.planItDataStorage, context: self.mainObjectContext) as! PlanItDataStorage
        newUsersDataStorage.totalSpace = storageData["maxDataSize"] as? Double ?? 0.0
        newUsersDataStorage.usedSpace = storageData["userDataSize"] as? Double ?? 0.0
        newUsersDataStorage.user = Session.shared.readUserId()
        self.mainObjectContext.saveContext()
        return newUsersDataStorage
    }
    
    func readUsersDataStorage(using context: NSManagedObjectContext? = nil) -> [PlanItDataStorage] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItDataStorage, predicate: predicate, context: objectContext) as! [PlanItDataStorage]
    }
}
