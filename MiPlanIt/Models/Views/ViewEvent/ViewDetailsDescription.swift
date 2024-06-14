//
//  ViewDetailsDescription.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ViewDetailsDescription: UIView, UITextViewDelegate {

    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var viewDescriptionData: UIView!
    @IBOutlet weak var descriptionArrow: UIImageView!
    
    @IBAction func showOtherDetailsView(_ sender: UIButton) {
        self.viewDescriptionData.isHidden = !self.viewDescriptionData.isHidden
        self.descriptionArrow.image = self.viewDescriptionData.isHidden ? #imageLiteral(resourceName: "side-arrow-icon") : #imageLiteral(resourceName: "down-arrow-icon")
    }
    
    func setDescription(_ description: String, htmlString: String, isGoogleEvent: Bool, conferenceData: String) {
        if (description.filter { !$0.isWhitespace }).isHtml() {
            self.textViewDescription.attributedText = self.makeHtmlDescription(description: description, conferenceData: conferenceData).htmlToAttributedString
        }
        else {
            self.textViewDescription.text = self.makeNormalDescription(description: description, conferenceData: conferenceData).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        self.textViewDescription.textColor = .white//remove this for showing links color
        if #available(iOS 13.0, *) {
            self.textViewDescription.linkTextAttributes = [.foregroundColor: UIColor.link]
        } else {
            // Fallback on earlier versions
        }
        self.textViewDescription.isUserInteractionEnabled = true
        self.textViewDescription.isSelectable = true
        self.textViewDescription.isEditable = false
        self.textViewDescription.delegate = self
        self.textViewDescription.dataDetectorTypes = .link
        self.isHidden = self.textViewDescription.text.isEmpty
        self.textViewDescription.dataDetectorTypes = .all
    }
    
    func makeHtmlDescription(description: String, conferenceData: String) -> String {
        return conferenceData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? description : (conferenceData + "<br><br>" + description)
    }
    
    func makeNormalDescription(description: String, conferenceData: String) -> String {
        return conferenceData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? description : (conferenceData + " \n " + description)
    }
}
