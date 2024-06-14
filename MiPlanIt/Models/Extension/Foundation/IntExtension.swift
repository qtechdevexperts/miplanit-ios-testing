//
//  IntExtension.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension Int {
    
    func getMonth() -> String {
        switch self {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default: return Strings.empty
        }
    }
    
    func getSetPosition() -> String {
        switch self {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        case 5: return "5th"
        case -1: return "last"
        default: return "\(self)th"
        }
    }
    
    func getWeekDay() -> String {
        switch self {
        case 1: return "Sun"
        case 2: return "Mon"
        case 3: return "Tue"
        case 4: return "Wed"
        case 5: return "Thu"
        case 6: return "Fri"
        default: return "Sat"
        }
    }
}
