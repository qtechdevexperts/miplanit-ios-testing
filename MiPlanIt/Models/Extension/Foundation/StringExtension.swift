//
//  StringExtension.swift
//  MiPlanIt
//
//  Created by Arun on 24/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import EventKit
// import RRuleSwift

extension String {
    
    var length: Int {
        return self.count
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func isHtml() -> Bool {
        let validateTest = NSPredicate(format:"SELF MATCHES %@", "<[a-z][\\s\\S]*>")
        let isHtml = validateTest.evaluate(with: self)
        if isHtml {
            return true
        }
        else {
            let str = self.replacingOccurrences(of: "<[^>]+>", with: "$#$", options: .regularExpression, range: nil)
            let subString = str.components(separatedBy:"$#$")
            return subString.count > 3
        }
    }
    
    func containLinks() -> Bool {
        return self.contains("https://") || self.contains("http://")
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(from: Int) -> String {
        return self[min(from, length) ..< length]
    }

    func substring(to: Int) -> String {
        return self[0 ..< max(0, to)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func checkPasswordValidation() -> [PasswordHintNames] {
        if self.isEmpty { return [] }
        var passwordHints: [PasswordHintNames] = []
        passwordHints.append(PasswordHintNames.contains8Charecter(status: self.containsAtLeast8Charecter()))
        passwordHints.append(PasswordHintNames.containsNumber(status: self.containsNumbers()))
        passwordHints.append(PasswordHintNames.containsSpecialCharecter(status: self.containsSpecialCharacter()))
        passwordHints.append(PasswordHintNames.containsLowercase(status: self.containsOneLowercase()))
        passwordHints.append(PasswordHintNames.containsUppercase(status: self.containsOneUppercase()))
        return passwordHints
    }
    
    func checkExpiry() -> String {
        let isoDate = self
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateFormatters.MMDDYYYYHMMSSA
        let date = dateFormatter.date(from:isoDate)!
        return date.convertDateToComponentsForExpiry()
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValidateEmail = validateEmail.evaluate(with: trimmedString)
        return isValidateEmail
    }
    
    func validatePhone() -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return self.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    func validateString() -> Bool {
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        return !trimmedString.isEmpty
    }
    
    func validateDate() -> Bool {
        return self.containsNumbers()
    }
    
    func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }
    
    func containsAtLeast8Charecter() -> Bool {
        return self.count >= 8
    }
    
    func containsSpecialCharacter() -> Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    func containsNumbers() -> Bool {
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func containsOneUppercase() -> Bool {
        let numberRegEx  = ".*[A-Z]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func containsOneLowercase() -> Bool {
        let numberRegEx  = ".*[a-z]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func toDateStrimg(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date? {
        let isoDate = self
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: isoDate)
        return date
    }
    
    func stringFrom(format: String, toFormat: String)-> String {
        let isoDate = self
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: isoDate)
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date!)
    }
    
    
    func stringToDate(formatter: String, timeZone: TimeZone = .current) -> Date? {
        if !self.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = formatter
            return dateFormatter.date(from: self)
        }
        return nil
        
    }
    
    //TimeZone(secondsFromGMT: 0)!
    
    func imageFromName(_ border: CGFloat = 0) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.textColor = self.isEmpty ? UIColor.lightText : UIColor.white
        nameLabel.backgroundColor = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        nameLabel.font = UIFont(name: Fonts.SFUIDisplayRegular, size: 40)
        nameLabel.text = self.isEmpty ? "UA" : self
        nameLabel.layer.cornerRadius = border == 0 ? 0 : 50
        nameLabel.clipsToBounds = true
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
    func shortString() -> String {
        let names = self.components(separatedBy: Strings.space)
        if names.count > 1 {
            let firstCharacter = names.first?.substring(to: 1) ?? Strings.empty
            let lastCharacter = names.last?.substring(to: 1) ?? Strings.empty
            return (firstCharacter + lastCharacter).uppercased()
        }
        else {
            let firstCharacter = names.first?.substring(to: 2) ?? Strings.empty
            return firstCharacter.uppercased()
        }
    }
    
    func shortStringImage(_ border: CGFloat = 0) -> UIImage? {
        let shortString = self.shortString()
        return shortString.imageFromName(border)
    }
    
    func attributedText() -> NSMutableAttributedString {
        let main_string = "Hello World"
        let string_to_color = "World"

        let range = (main_string as NSString).range(of: string_to_color)

        let attribute = NSMutableAttributedString.init(string: main_string)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        return attribute
    }
    
    func attributedPlaceholder(subtext: String) -> NSMutableAttributedString {
        let futuraFont:UIFont =  UIFont(name: Fonts.SFUIDisplayRegular, size: 18)!
        let futuraDictionary:NSDictionary = NSDictionary.init(object: futuraFont, forKey: NSAttributedString.Key.font as NSCopying)
        let menloFont:UIFont =  UIFont(name: Fonts.SFUIDisplayRegular, size: 13)!
        let menloDictionary:NSDictionary = NSDictionary.init(object: menloFont, forKey: NSAttributedString.Key.font as NSCopying)
        let mAttrString:NSMutableAttributedString = NSMutableAttributedString.init(string: subtext, attributes: menloDictionary as? [NSAttributedString.Key : Any])
        let fAttrString:NSMutableAttributedString = NSMutableAttributedString.init(string: self, attributes: (futuraDictionary as? [NSAttributedString.Key : Any]) )
        fAttrString.append(mAttrString)
        return fAttrString
    }
    
    func addNotificationAttributedString(_ string: String) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: self))
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ]
        let myAttrString = NSAttributedString(string: string, attributes: myAttribute)
        result.append(myAttrString)
        return result
    }
    
    func slice(from: String, to: String? = nil) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            if let endString = to {
                return (range(of: endString, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                    String(self[substringFrom..<substringTo])
                }
            }
            else {
                return String(self[substringFrom...])
            }
        }
    }
    
    func showCardNumber() -> String {
        return "XXXX-XXXX-XXXX-\(self.suffix(4))"
    }
    
    func getColor() -> UIColor? {
        let colorCode = self.split(separator: " ").map({ String($0) })
        if colorCode.count == 3, let red = Double(colorCode[0]), let green = Double(colorCode[1]), let blue = Double(colorCode[2])  {
            return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        }
        return nil
//        return self.readCalendarColorFromCode(self)
    }
    
    func readCalendarColorFromCode(_ code: String?) -> Color? {
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
    
    
    func getColorWithOpacity() -> UIColor? {
        let colorCode = self.split(separator: " ").map({ String($0) })
        if colorCode.count == 3, let red = Double(colorCode[0]), let green = Double(colorCode[1]), let blue = Double(colorCode[2])  {
            return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 0.76)
        }
        return nil
    }
    
    func getfrequencyFromString() -> RecurrenceFrequency {
        switch self.uppercased() {
        case "SECONDLY": return .secondly
        case "MINUTELY": return .minutely
        case "HOURLY": return .hourly
        case "DAILY": return .daily
        case "WEEKLY": return .weekly
        case "MONTHLY": return .monthly
        case "YEARLY": return .yearly
        case "RELATIVEMONTHLY": return .monthly
        case "ABSOLUTEMONTHLY": return .monthly
        default: return .daily
        }
    }
    
    func getfirstDayofWeekFromString() -> EKWeekday {
        switch self.lowercased() {
        case "sunday": return .sunday
        case "monday": return .monday
        case "tuesday": return .tuesday
        case "wednesday": return .wednesday
        case "thursday": return .thursday
        case "friday": return .friday
        case "saturday": return .saturday
        default: return .sunday
        }
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func getPositionSuffix() -> String {
        switch self {
        case "1": return self+"st "
        case "2": return self+"nd "
        case "3": return self+"rd "
        case "-1": return "last"
        default: return self+"th "
        }
    }
    
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlHostAllowed)
    }
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
    
    func getLocalCurrencySymbol() -> String {
        var locale = Locale.current
        if (locale.currencyCode != self) {
            let identifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: self])
            locale = NSLocale(localeIdentifier: identifier) as Locale
        }
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        return currencyFormatter.currencySymbol
    }
}

extension NSMutableAttributedString {
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : UIFont] = [
            .font : UIFont(name: Fonts.SFUIDisplayRegular, size: 17)!
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : UIFont] = [
            .font : UIFont(name: Fonts.SFUIDisplayRegular, size: 12)!,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension NSAttributedString {
    func getAttrStrOf(string: String, font: UIFont) -> NSAttributedString {
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.init(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0),  NSAttributedString.Key.font: font ]
        let result = NSAttributedString(string: string, attributes: myAttribute)
        return result
    }
}
