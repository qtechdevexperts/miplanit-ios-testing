//
//  PrivateManagedObjectContext.swift
//  EZCapture
//
//  Created by Richin.C on 24/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import CoreData

class PrivateManagedObjectContext: NSManagedObjectContext {
    
    override func save() throws {
        try super.save()
        self.saveMainObjectContext()
    }
    
    func saveMainObjectContext() {
        if let mainObjectContext = self.parent as? MainManagedObjectContext {
            mainObjectContext.perform { [weak self] in
                guard let _ = self else { return }
                mainObjectContext.saveContext() }
        }
    }
}
