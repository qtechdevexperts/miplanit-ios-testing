//
//  DatabasePlanItPurchaseCard.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItPurchaseCard: DataBaseManager {
    
    func insertCard(_ card: [String: Any], for purchase: PlanItPurchase, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let cardEntity = purchase.card ?? self.insertNewRecords(Table.planItPurchaseCard, context: objectContext) as! PlanItPurchaseCard
        cardEntity.cardName = card["cardName"] as? String
        cardEntity.cardNumber = card["cardNo"] as? String
        cardEntity.purchase = purchase
    }
    
    
    
    func insertCard(_ card: PurchaseCard, for purchase: PlanItPurchase, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let cardEntity = purchase.card ?? self.insertNewRecords(Table.planItPurchaseCard, context: objectContext) as! PlanItPurchaseCard
        cardEntity.cardName = card.cardName
        cardEntity.cardNumber = card.cardNumber
        cardEntity.purchase = purchase
    }
    
}
