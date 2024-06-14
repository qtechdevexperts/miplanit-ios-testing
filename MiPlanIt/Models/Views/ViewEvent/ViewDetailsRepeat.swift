//
//  ViewDetailsRepeat.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsRepeat: UIView {

    @IBOutlet weak var labelRepeatTitle: UILabel!
    @IBOutlet weak var labelRepeatUntil: UILabel!
    
    func setRepeatDate(recurrence: String?, at date: Date, endate: Date) {
        guard let recurrenceValue = recurrence else { return }
        self.setTitle(recurrence: recurrenceValue, at: date)
        self.setUntil(recurrence: recurrenceValue, at: date, endate: endate)
    }
    
    private func getFrequency(recurrence: String) -> String? {
        if let repeatValue = recurrence.slice(from: "FREQ=", to: ";") {
            return repeatValue
        }
        else if let repeatValue = recurrence.slice(from: "FREQ=") {
            return repeatValue
        }
        return nil
    }
    
    private func getRepeatValueType(recurrence: String) -> DropDownOptionType {
        if let repeatValue = self.getFrequency(recurrence: recurrence) {
            switch repeatValue.uppercased() {
            case "DAILY":
                return .eEveryDay
            case "WEEKLY":
                return .eEveryWeek
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .eEveryMonth
            case "YEARLY":
                 return .eEveryYear
            default:
                break
            }
        }
        return .eNever
    }
    
    private func setTitle(recurrence: String, at date: Date) {
        var repeatTitle = ""
        let endTime = date.stringFromDate(format: DateFormatters.HHMMSA)
        
        switch self.getRepeatValueType(recurrence: recurrence) {
        case .eEveryDay:
            repeatTitle = "REPEATS DAILY "+endTime
        case .eEveryWeek:
            repeatTitle = "REPEATS WEEKLY "+endTime
        case .eEveryMonth:
            repeatTitle = "REPEATS MONTHLY "+endTime
        case .eEveryYear:
            repeatTitle = "REPEATS YEARLY "+endTime
        default:
            repeatTitle = Strings.empty
        }
        self.labelRepeatTitle.text = repeatTitle
    }
    
    private func setUntil(recurrence: String, at date: Date, endate: Date) {
        self.labelRepeatUntil.text = Strings.empty
        if let range = recurrence.range(of: "UNTIL=") {
            let untilDate = recurrence[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if let dateUntil = untilDate.toDate(withFormat: DateFormatters.YYYMMDD) {
                self.labelRepeatUntil.text = "Until: " + dateUntil.stringFromDate(format: DateFormatters.DDHMMHYYYY)
            }
        }
    }

}
