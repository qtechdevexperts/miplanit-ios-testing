//
//  CalendarImageView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CalendarImageViewDelegate: class {
    func calendarImageView(_ calendarImageView: CalendarImageView, selectedImage: UIImage?)
}

class CalendarImageView: UIView {

    @IBOutlet weak var imageViewCalendar: UIImageView!
    @IBOutlet weak var buttonImage: UIButton!
    @IBOutlet weak var imageViewSelection: UIImageView?
    
    weak var delegate: CalendarImageViewDelegate?
    
    @IBAction func imageSelectionClicked(_ sender: UIButton) {
        self.delegate?.calendarImageView(self, selectedImage: self.imageViewCalendar.image)
    }
    
    func resetSelection() {
        self.buttonImage.imageView?.frame = self.buttonImage.frame
        self.buttonImage.isSelected = false
        self.imageViewSelection?.isHidden = true
    }
    
    func setSelection() {
        self.buttonImage.imageView?.frame = self.buttonImage.frame
        self.buttonImage.isSelected = true
        self.imageViewSelection?.isHidden = false
    }

}
