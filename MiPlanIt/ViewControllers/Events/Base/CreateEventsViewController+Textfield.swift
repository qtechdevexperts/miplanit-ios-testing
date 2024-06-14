//
//  CreateEventsViewController+Textfield.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift


extension CreateEventsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        switch textField {
        case self.textFieldLocation:
            self.textFieldLocation.text = self.eventModel.setLocation(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty)
        case self.textFieldEventName:
            self.eventModel.eventName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateEventsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        IQKeyboardManager.shared.enableAutoToolbar = false
        if textView == self.textViewDescription {
            if let attributedText = textView.attributedText {
                if !attributedText.string.isHtml() {
                    self.eventModel.eventDescription = attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                else {
                    do {
                        let htmlData = try attributedText.data(from: .init(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
                        let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
                        self.eventModel.eventDescription = htmlString.trimmingCharacters(in: .whitespacesAndNewlines)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
