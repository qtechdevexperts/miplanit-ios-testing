//
//  DatabasePlanItExcludedSection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItExcludedSections: DataBaseManager {

    func insertExcludedSection(_ section: [String], for dashboard: PlanItDashboard, using context: NSManagedObjectContext? = nil) {
        dashboard.deleteExcludedSection()
        let objectContext = context ?? self.mainObjectContext
        for eachSection in section {
            let tagEntity = self.insertNewRecords(Table.planItExcludedSections, context: objectContext) as! PlanItExcludedSections
            tagEntity.dashboard = dashboard
            tagEntity.sectionName = eachSection
        }
    }

}
