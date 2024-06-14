//
//  CalendarListBaseViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import EventKit
import Lottie

protocol CalendarListBaseViewControllerDelegate: class {
    func calendarListBaseViewController(_ calendarListBaseViewController: CalendarListBaseViewController, allAddedColorCodes: [ColorCode])
}

class CalendarListBaseViewController: UIViewController {
    
    var calendarType: MiPlanItEnumCalendarType!
    var outlookAuthenticationCode: String = Strings.empty
    var outlookRedirectionUrl: String = Strings.empty
    
    @IBOutlet weak var tableViewCalanderList: UITableView!
    @IBOutlet weak var viewCalanderStatus: UIView!
    @IBOutlet weak var viewErrorStatus: UIView!
    @IBOutlet weak var buttonSyncCalendar: ProcessingButton!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var imgCalendarType: UIImageView!
    @IBOutlet weak var labelCalendarOwner: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelCalendarCaption: UILabel!
    @IBOutlet weak var viewCalendarOwner: UIView!
    @IBOutlet weak var viewLoadingContainer: UIView?
    @IBOutlet weak var labelLoadingContent: UILabel?
    @IBOutlet weak var dotLoader: DotsLoader?
    var calanderList: [SocialCalendar] = [] {
        didSet {
            self.stopLottieAnimations()
            self.tableViewCalanderList.reloadData()
        }
    }
    
    var appliedColorCodeObjects: [ColorCode] = []
    weak var delegate: CalendarListBaseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.intialiseUIComponents()
        self.readEventsAfterNavigation()
    }
    
    //MARK: - Override
    func importCalendarSuccessfully() { }
    
    //MARK:- Actions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func syncCalanderButtonClicked(_ sender: ProcessingButton) {
        let importedCalendars = self.calanderList.filter({ return $0.calendarStatus == .completed })
        guard !importedCalendars.isEmpty else { return }
        self.createServiceToImportCalendarEvents(importedCalendars)
    }
    
    @IBAction func retryActionButtonClicked(_ sender: Any) {
        self.readEventsAfterNavigation()
    }
    
    @IBAction func skipButtonClicked(_ sender: Any) { }
    
    @IBAction func cancelButtonClicked(_ sender: Any) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
