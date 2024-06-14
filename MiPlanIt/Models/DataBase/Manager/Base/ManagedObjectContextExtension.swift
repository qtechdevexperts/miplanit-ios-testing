//
//  ManagedObjectContextExtension.swift
//  MiPlanIt
//
//  Created by Arun on 06/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func saveContext() {
        if self.hasChanges {
            do { try self.save() }
            catch {
                print("Ops there was an error \(error.localizedDescription)")
                abort() }
        }
    }
}
