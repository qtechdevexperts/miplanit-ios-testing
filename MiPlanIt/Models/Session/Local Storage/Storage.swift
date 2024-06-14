//
//  Storage.swift
//  WorkJoe
//
//  Created by MAC6 on 12/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class Storage {
        
    func saveConfidentialData(_ data: String, forkey key: String) {
        KeychainWrapper.standard.set(data, forKey: key)
    }
    
    func readConfidentialDataForKey(_ key: String) -> String? {
        return KeychainWrapper.standard.string(forKey: key)
    }

    func saveString(object: String, forkey key: String) {
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func saveTodaysCount(object: [String: String], forkey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func readTodaysCount(_ key: String) -> [String: String]? {
        return UserDefaults.standard.object(forKey: key) as? [String: String]
    }
    
    func readString(_ key: String) -> String? {
        return UserDefaults.standard.object(forKey: key) as? String
    }
    
    func readBool(_ key: String) -> Bool? {
        return UserDefaults.standard.object(forKey: key) as? Bool
    }
    
    func saveBool(flag: Bool, forkey key: String) {
        UserDefaults.standard.set(flag, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //MARK:- country code
    func readCountries() -> [Country] {
        if let path = Bundle.main.path(forResource: FileNames.country, ofType: Extensions.fileTypePlist) {
            if let countries = NSArray(contentsOfFile: path) as? [[String: String]] {
                return countries.map({ return Country(data: $0) })
            }
        }
        return []
    }
    
    func readDefaultCountryCodeOnPhone() -> String {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String, let country = self.readCountries().filter({ return $0.code.lowercased() == countryCode.lowercased() }).first {
            return country.phone
        }
        return Strings.empty
    }
    
    func readCalendarColorFromCode(_ code: String?) -> Color {
        let plist = Session.shared.colors
        if let colorCode = code, !colorCode.isEmpty {
            if let colorData = plist.filter({ $0.readColorCodeKey() == colorCode }).first, let color = colorData.readCalendarColor() {
                return color
            }
        }
        if let defaultColorData = plist.filter({ $0.isDefault }).first, let color = defaultColorData.readCalendarColor() {
            return color
        }
        else {
            return  UIColor.blue.withAlphaComponent(0.3)
        }
    }
    
    func readTextColorFromCode(_ code: String?) -> Color {
        let plist = Session.shared.colors
        if let colorCode = code, !colorCode.isEmpty {
            if let colorData = plist.filter({ $0.readColorCodeKey() == colorCode }).first, let color = colorData.readTextColor() {
                return color
            }
        }
        if let defaultColorData = plist.filter({ $0.isDefault }).first, let color = defaultColorData.readTextColor() {
            return color
        }
        else {
            return  UIColor.blue.withAlphaComponent(0.3)
        }
    }
    
    func readEventBGColorFromCode(_ code: String?) -> Color {
        let plist = Session.shared.colors
        if let colorCode = code, !colorCode.isEmpty {
            if let colorData = plist.filter({ $0.readColorCodeKey() == colorCode }).first, let color = colorData.readEventBGColor() {
                return color
            }
        }
        if let defaultColorData = plist.filter({ $0.isDefault }).first, let color = defaultColorData.readEventBGColor() {
            return color
        }
        else {
            return  UIColor.blue.withAlphaComponent(0.3)
        }
    }
    
    func getColorCodes() -> [ColorCode] {
        let colorCodes = Session.shared.colors
        return  colorCodes.filter { (color) -> Bool in
            !color.isDefault
        }.sorted(by: { $0.order < $1.order })
    }
    
    func getAllColorCodes() -> [ColorCode] {
        return Session.shared.colors
    }
    
    func getDefaultColorCodes() -> ColorCode? {
        let colorCodes = Session.shared.colors
        return  colorCodes.filter { (color) -> Bool in
            color.isDefault
        }.first
    }
    
    func getRandomColorCode() -> ColorCode? {
        return self.getColorCodes().randomElement()
    }
    
    func getAllDashboardCards() -> [DashboardCard] {
        return Session.shared.dashboardCards
    }
}
