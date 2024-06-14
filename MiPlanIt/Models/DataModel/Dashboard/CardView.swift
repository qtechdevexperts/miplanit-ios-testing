//
//  CardView.swift
//  SwipeCards
//
//  Created by Febin Paul on 23/09/20.
//  Copyright © 2020 Febin Paul. All rights reserved.
//

import Foundation
import UIKit

class DashboardCard {
    
    var bgColorCode: String = Strings.empty
    var bgColorCode2: String = Strings.empty
    var bgColorCodeCount: String = Strings.empty
    var borderColorCode: String  = Strings.empty
    var borderColorCodeCount: String  = Strings.empty
    var titleColor: String  = Strings.empty
    var dashBoardTitle: DashBoardTitle! = .event
    
    init(_ cardData: [String: Any]) {
        guard let type = cardData["type"] as? String else { return }
        switch type {
        case "event":
            self.dashBoardTitle = .event
        case "todo":
            self.dashBoardTitle = .toDo
        case "gift":
            self.dashBoardTitle = .giftCard
        case "purchase":
            self.dashBoardTitle = .purchase
        default:
            self.dashBoardTitle = .shopping
        }
        self.borderColorCode = cardData["borderColorCode"] as? String ?? Strings.empty
        self.borderColorCodeCount = cardData["borderColorCodeCount"] as? String ?? Strings.empty
        self.bgColorCode = cardData["bgColorCode"] as? String ?? Strings.empty
        self.bgColorCode2 = cardData["bgColorCode2"] as? String ?? Strings.empty
        self.bgColorCodeCount = cardData["bgColorCodeCount"] as? String ?? Strings.empty
        self.titleColor = cardData["titleColor"] as? String ?? Strings.empty
    }
}

class CardView {
    
    var dashboardCard: DashboardCard!
    var activeDateSection: DashBoardSection = .today
    var cardItemData: [Any] = []
    var overDueData: [PlanItTodo] = []
    private var processing: Bool = false
    
    init(dashboardCard: DashboardCard) {
        self.dashboardCard = dashboardCard
    }
    
    func updateData(data: [Any]) {
        self.processing = false
        self.cardItemData = data
    }
    
    func setProcessing(_ flag: Bool) {
        self.processing = true
    }
    
    func updateOverdueData(_ data: [PlanItTodo]) {
        self.overDueData = data
    }
    
    var isProcessing: Bool {
        get {
            return self.processing
        }
    }
}
