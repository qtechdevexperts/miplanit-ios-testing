//
//  ArrayExtension.swift
//  MiPlanIt
//
//  Created by Arun on 05/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Array where Element == ServiceDetection {
    
    func isContainedSpecificServiceData(_ type: ServiceOutPut) -> Bool {
        var isServiceOutExist = false
        for detected in self {
            switch detected {
            case .newCalendar(_):
                if !isServiceOutExist && type == .calendar { isServiceOutExist = true }
            case .calendarDeleted(_):
                if !isServiceOutExist && type == .calendar { isServiceOutExist = true }
            case .newEvent(_):
                if !isServiceOutExist && type == .calendar { isServiceOutExist = true }
            case .eventDeleted(_):
                if !isServiceOutExist && type == .calendar { isServiceOutExist = true }
            case .newPurchase:
                if !isServiceOutExist && type == .purchase { isServiceOutExist = true }
            case .purchaseDeleted:
                if !isServiceOutExist && type == .purchase { isServiceOutExist = true }
            case .newGiftCoupon:
                if !isServiceOutExist && type == .gift { isServiceOutExist = true }
            case .giftCouponDeleted:
                if !isServiceOutExist && type == .gift { isServiceOutExist = true }
            case .todo:
                if !isServiceOutExist && type == .todo { isServiceOutExist = true }
            case .todoDeleted:
                if !isServiceOutExist && type == .todo { isServiceOutExist = true }
            case .newShopping:
                if !isServiceOutExist && type == .shop { isServiceOutExist = true }
            case .shoppingDeleted:
                if !isServiceOutExist && type == .shop { isServiceOutExist = true }
            case .eventShareLink:
                if !isServiceOutExist && type == .eventShareLink { isServiceOutExist = true }
            case .eventShareLinkDeleted:
                if !isServiceOutExist && type == .eventShareLink { isServiceOutExist = true }
            }
        }
        return isServiceOutExist
    }
}


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array where Element: Comparable & Hashable {
    func sortByNumberOfOccurences() -> [Element] {
        let occurencesDict = self.reduce(into: [Element:Int](), { currentResult, element in
            currentResult[element, default: 0] += 1
        })
        return self.sorted(by: { current, next in occurencesDict[current]! < occurencesDict[next]!})
    }
    
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
