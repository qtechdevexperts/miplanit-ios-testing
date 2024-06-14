//
//  Shop.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopList {
    
    var shopId = Strings.empty
    var appShopId = Strings.empty
    var shopListName = Strings.empty
    var shopDescription = Strings.empty
    var shopColorCode = Strings.empty
    var shopImageName = Strings.empty
    var isCustom = false
    var createdDate = Date()
    var shareInvitees: [OtherUser] = []
    var shopListData: PlanItShopList?
    var shopListItems: [PlanItShopListItems] = []
    var isPending: Bool = false
    var shopListImageData: Data?
    
    
    init() { }

    init(with planItShop: PlanItShopList) {
        self.appShopId = planItShop.readAppShopListID()
        self.shopId = planItShop.readShopListID()
        self.shopListName = planItShop.readShopListName()
        self.shopColorCode = planItShop.readShopListColor()
        self.shopImageName = planItShop.readShopListImage()
        self.shopListData = planItShop
        self.isPending = planItShop.isPending
        self.shopListImageData = planItShop.shopListImageData
        self.shareInvitees = planItShop.readAllShopListShareInvitees().map({ OtherUser(invitee: $0) }).filter({ $0.userId != Session.shared.readUserId() })
    }
    
    func resetAllUndoActivity() {
    }
    
    func readOtherInvitees() -> [OtherUser] {
        return self.shareInvitees.filter({ $0.userId != Session.shared.readUserId() })
    }
    
    func createRequestParams(removingCurrentUser: Bool = false) -> [String: Any] {
        var parameter: [String: Any] = [:]
        if !self.shopId.isEmpty && self.shopId != "0" {
            parameter["shpListId"] = self.shopId
        }
        parameter["shpListName"] = self.shopListName
        parameter["appShpListId"] = self.appShopId
        parameter["shpListColourCode"] = self.shopColorCode
        parameter["invitees"] = self.createInvitees(removingCurrentUser: removingCurrentUser)
        return parameter
    }
    
    func createInvitees(removingCurrentUser: Bool = false) -> [[String: Any]] {
        let userIds = self.shareInvitees.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId] })
        let emails = self.shareInvitees.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email] })
        let phones = self.shareInvitees.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone] })
        let users = userIds + emails + phones
        return removingCurrentUser ? users : (users + [["userId": Session.shared.readUserId()]])
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
//        text += self.shopListName
//        text += self.readAllMainProducts().count > 0 ? ", "+self.readAllMainProducts().compactMap({$0.itemName}).joined(separator: ", ") : ""
        return text
    }
}
