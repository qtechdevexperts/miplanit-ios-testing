//
//  ViewDetailsDataValue.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsDataValue: UIView {

    @IBOutlet weak var labelDataValue: UILabel?
    @IBOutlet weak var textViewDataValue: UITextView?
    @IBOutlet weak var viewID: UIView?
    @IBOutlet weak var viewPasscode: UIView?
    @IBOutlet weak var labelID: UILabel?
    @IBOutlet weak var labelPasscode: UILabel?
    @IBOutlet weak var buttonValueSelect: UIButton?
    
    func setValue(_ value: String) {
        self.isHidden = value.isEmpty
        self.labelDataValue?.text = value
        self.textViewDataValue?.text = value
    }
    
    func setLocationValue(_ value: String) {
        let locatinData = value.split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            self.labelDataValue?.text = String(locationName)
            self.textViewDataValue?.text = String(locationName)
            self.buttonValueSelect?.isUserInteractionEnabled = locatinData.count > 2
            if locatinData.count > 2 {
                if #available(iOS 13.0, *) {
                    self.textViewDataValue?.textColor = .white//Color.link
                } else {
                    self.textViewDataValue?.textColor = .white//Color(red: 0, green: 0, blue: 238/255, alpha: 1.0)
                }
            }
        }
        self.labelDataValue?.isHidden = true
        self.isHidden = value.isEmpty
    }
    
    func setConferenceData(conferenceType: ConferenceType, entryPoints: [[String: Any]]) {
        self.textViewDataValue?.text = Strings.empty
        self.labelID?.text = Strings.empty
        self.labelPasscode?.text = Strings.empty
        if let phoneEntryPoint = entryPoints.filter({ data in
            if let type = data["entryPointType"] as? String, type == conferenceType.rawValue {
                return true
            }
            return false
        }).first {
            if let label = phoneEntryPoint["label"] as? String {
                self.textViewDataValue?.text = label
            }
            if conferenceType == .video, let label = phoneEntryPoint["uri"] as? String {
                self.textViewDataValue?.text = label
            }
            if let accessCode = phoneEntryPoint["accessCode"] as? String {
                self.labelID?.text = "ID: "+accessCode
            }
            if let passcode = phoneEntryPoint["passcode"] as? String {
                self.labelPasscode?.text = "Passcode: "+passcode
            }
        }
        self.isHidden = self.textViewDataValue?.text?.isEmpty ?? true
        self.viewID?.isHidden = self.labelID?.text?.isEmpty ?? true
        self.viewPasscode?.isHidden = self.labelPasscode?.text?.isEmpty ?? true
    }
    
    func setPhoneConferenceData(_ conferenceString: String) {
        let conferenceData = self.readConferenceData(conferenceString)
        if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]] {
            self.setConferenceData(conferenceType: .phone, entryPoints: entryPoints)
        }
    }
    
    func setSIPConferenceData(_ conferenceString: String) {
        let conferenceData = self.readConferenceData(conferenceString)
        if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]] {
            self.setConferenceData(conferenceType: .sip, entryPoints: entryPoints)
        }
    }
    
    func setVideoConferenceData(_ conferenceString: String) {
        let conferenceData = self.readConferenceData(conferenceString)
        if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]] {
            self.setConferenceData(conferenceType: .video, entryPoints: entryPoints)
        }
    }
        
    func readConferenceData(_ conferenceString: String) -> [String: Any] {
        let data = conferenceString.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] { return jsonArray }
            else { return [:] }
        } catch _ as NSError { return [:] }
    }
    
    func setReminderValueAndUnit(_ reminder: Any) {
        var reminderInterval: Double = 0.0
        if let planItReminder = reminder as? PlanItReminder {
            reminderInterval = planItReminder.readInterval()
        }
        else if let otherUserReminders = reminder as? OtherUserReminders {
            reminderInterval = otherUserReminders.interval
        }
        if reminderInterval != 0.0 {
            if reminderInterval > 59 {
                if reminderInterval.truncatingRemainder(dividingBy: 60) == 0 && reminderInterval <= 1380 {
                    let value = Int(reminderInterval/60.0)
                    self.labelDataValue?.text = "\(value)" + " \(Strings.hourUnit+(value > 1 ? "s": Strings.empty)) " + "before"
                    
                }
                else if reminderInterval.truncatingRemainder(dividingBy: 1440) == 0 && reminderInterval > 1380 && reminderInterval <= 8640 {
                    let value = Int(reminderInterval/1440)
                    self.labelDataValue?.text = "\(value)" + " \(Strings.dayUnit+(value > 1 ? "s": Strings.empty)) " + "before"
                }
                else if reminderInterval.truncatingRemainder(dividingBy: 10080) == 0 && reminderInterval > 8640 && reminderInterval <= 514080 {
                    let value = Int(reminderInterval/10080)
                    self.labelDataValue?.text = "\(value)" + " \(Strings.weekUnit+(value > 1 ? "s": Strings.empty)) " + "before"
                }
                else {
                    let value = Int(reminderInterval/60.0)
                    self.labelDataValue?.text = "\(value)" + " \(Strings.hourUnit+(value > 1 ? "s": Strings.empty)) " + "before"
                }
            }
            else {
                if reminderInterval == 5 {
                    self.labelDataValue?.text = "5" + " \(Strings.minUnit+"s") " + "before"
                }
                else if reminderInterval == 15 {
                    self.labelDataValue?.text = "15" + " \(Strings.minUnit+"s") " + "before"
                }
                else if reminderInterval == 30 {
                    self.labelDataValue?.text = "30" + " \(Strings.minUnit+"s") " + "before"
                }
                else {
                    let value = Int(reminderInterval)
                    self.labelDataValue?.text = "\(value)" + " \(Strings.minUnit+(value > 1 ? "s": Strings.empty)) " + "before"
                }
            }
        }
    }
}
