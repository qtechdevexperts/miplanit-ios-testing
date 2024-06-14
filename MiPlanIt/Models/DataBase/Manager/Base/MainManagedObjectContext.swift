//
//  MainManagedObjectContext.swift
//  EZCapture
//
//  Created by Richin.C on 24/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import CoreData

class MainManagedObjectContext: NSManagedObjectContext {
    
    override func save() throws {
        try super.save()
        self.saveMasterObjectContext()
    }
    
    func saveMasterObjectContext() {
        if let masterContext = self.parent {
            masterContext.perform { [weak self] in
                guard let _ = self else { return }
                masterContext.saveContext() }
        }
    }
}
