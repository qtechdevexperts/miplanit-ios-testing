//
//  DatabasePlanItSettings.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItSettings: DataBaseManager {
    
    func insertUserNewSettings(using context: NSManagedObjectContext? = nil) -> PlanItSettings {
        let objectContext = context ?? self.mainObjectContext
        return self.insertNewRecords(Table.planItSettings, context: objectContext) as! PlanItSettings
    }
}
