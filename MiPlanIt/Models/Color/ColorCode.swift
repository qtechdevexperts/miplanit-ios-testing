//
//  ColorCode.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ColorCode: Hashable {
    
    private var colorCodeKey: String!
    private var colorCodeCalendarColor: String!
    private var colorCodeTextValue: String!
    private var colorCodeEventBG: String!
    var order: Int = 0
    var colorCodeImageName: String!
    var colorCodeImageNameSelected: String!
    var isDefault: Bool = false
    
    init(_ dict: [String: Any]) {
        self.colorCodeKey = dict["colorCodeKey"] as? String ?? Strings.empty
        self.colorCodeCalendarColor = dict["colorCodeCalendarColor"] as? String ?? Strings.empty
        self.colorCodeTextValue = dict["colorCodeTextValue"] as? String ?? Strings.empty
        self.colorCodeEventBG = dict["colorCodeEventBG"] as? String ?? Strings.empty
        self.order = dict["order"] as? Int ?? 0
        self.colorCodeImageName = dict["colorCodeImageName"] as? String ?? Strings.empty
        self.colorCodeImageNameSelected = dict["colorCodeImageNameSelected"] as? String ?? Strings.empty
        self.isDefault = dict["isDefault"] as? Bool ?? false
    }
    
    func readTextColor() -> UIColor? {
        return colorCodeTextValue.getColor()
    }
    
    func readCalendarColor() -> UIColor? {
        return colorCodeCalendarColor.getColor()
    }
    
    func readEventBGColor() -> UIColor? {
        return colorCodeEventBG.getColor()
    }
    
    func readColorCodeKey() -> String {
        return colorCodeKey
    }
    
    static func == (lhs: ColorCode, rhs: ColorCode) -> Bool {
        return lhs.colorCodeKey == rhs.colorCodeKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(colorCodeKey)
    }
    
}

extension ColorCode: Comparable {
    
    static func < (lhs: ColorCode, rhs: ColorCode) -> Bool {
        return lhs.colorCodeKey < rhs.colorCodeKey
    }
}
