//
//  DatabasePlanItUserPayment.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class DatabasePlanItUserPayment: DataBaseManager {
    
    func insertNewPaymentCard(_ name: String, number: String) {
        let localPaymentCards = self.readUserPaymentCards()
        let newPaymentCard = localPaymentCards.filter({ return $0.cardNumber == number }).first ?? self.insertNewRecords(Table.planItUserPayment, context: self.mainObjectContext) as! PlanItUserPayment
        newPaymentCard.cardName = name
        newPaymentCard.cardNumber = number
        newPaymentCard.userId = Session.shared.readUserId()
        self.mainObjectContext.saveContext()
    }
    
    func readUserPaymentCards() -> [PlanItUserPayment] {
        let predicate = NSPredicate(format: "userId == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItUserPayment, predicate: predicate, context: self.mainObjectContext) as! [PlanItUserPayment]
    }
}
