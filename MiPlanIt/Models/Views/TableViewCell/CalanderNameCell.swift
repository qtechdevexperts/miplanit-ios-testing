//
//  CalanderNameCell.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//


import UIKit

protocol CalanderNameCellDelegare: class {
    func calanderNameCell(_ calanderNameCell: CalanderNameCell, selectedCalendarItem calander: SocialCalendar)
}

class CalanderNameCell: UITableViewCell {
    
    @IBOutlet weak var labelCalanderName: UILabel!
    @IBOutlet weak var buttonCloudDownload: UIButton!
    @IBOutlet weak var viewCircularProgress: UIView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var index: IndexPath!
    var calander: SocialCalendar!
    weak var delegate: CalanderNameCellDelegare?
    
    lazy var circularProgressBar: CircularProgressBar = {
        let progresBar = CircularProgressBar(radius: 19, position: CGPoint.init(x: 19, y: 19), innerTrackColor: UIColor.init(red: 105.0/255.0, green: 192.0/255.0, blue: 68.0/255.0, alpha: 1), outerTrackColor: UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1), lineWidth: 2)
        self.viewCircularProgress.layer.addSublayer(progresBar)
        return progresBar
    }()
    
    func configure( calander: SocialCalendar, indexPath: IndexPath, callBack: CalanderNameCellDelegare?) {
        self.index = indexPath
        self.delegate = callBack
        self.calander = calander
        self.labelCalanderName.text = calander.calendarName
        self.resetCalanderItemWithStatus()
    }
    
    func resetCalanderItemWithStatus() {
        if self.calander.calendarStatus == .started {
            self.progressIndicator.startAnimating()
        }
        else { self.progressIndicator.stopAnimating() }
        self.buttonCloudDownload.isSelected = self.calander.calendarStatus == .completed
        self.buttonCloudDownload.isHidden = self.calander.calendarStatus == .started
        self.viewCircularProgress.isHidden = !self.progressIndicator.isAnimating
        self.circularProgressBar.progress = CGFloat(self.calander.calendarProgress)
    }
    
    @IBAction func downloadEventButtonClicked(_ sender: UIButton) {
        guard let socialCalnder = self.calander, socialCalnder.calendarStatus == .pending else { return }
        sender.isHidden = true
        self.delegate?.calanderNameCell(self, selectedCalendarItem: socialCalnder)
    }
    
    func startedDownloadProcess() {
        self.circularProgressBar.progress = 0
        self.viewCircularProgress.isHidden = false
        self.progressIndicator.startAnimating()
    }
}
