//
//  CreateShareLinkViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol CreateShareLinkViewControllerDelegate: AnyObject {
    func createShareLinkViewControllerDataUpdated(_ createShareLinkViewController: CreateShareLinkViewController)
}

class CreateShareLinkViewController: UIViewController {
    
    var shareLinkModel = MiPlanitShareLink()
    weak var delegate: CreateShareLinkViewControllerDelegate?
    
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var dayDatePicker: DayDatePicker!
    @IBOutlet var buttonToggleCalendar: [UIButton]!
    @IBOutlet weak var buttonEndDate: UIButton!
    @IBOutlet weak var imageReminderSideArrow: UIImageView!
    @IBOutlet weak var buttonRemoveReminder: UIButton!
    @IBOutlet weak var buttonRemind: UIButton!
    @IBOutlet weak var buttonInvitees: UIButton!
    @IBOutlet weak var buttonDuration: UIButton!
    @IBOutlet weak var textFieldLocation: FloatingTextField!
    @IBOutlet weak var textFieldEventName: FloatingTextField!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var buttonCalendar: UIButton!
    @IBOutlet weak var buttonTimeRange: UIButton!
    @IBOutlet weak var buttonSaveShareLink: ProcessingButton!
    @IBOutlet weak var labelShareLinkTagCount: UILabel!
    @IBOutlet weak var buttonStartDate: UIButton!
    @IBOutlet weak var switchExcludeWeekend: UISwitch!
    @IBOutlet weak var buttonRemoveInvitee: UIButton!
    @IBOutlet weak var imageViewSideArrowInvitee: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setIntialValuesForScreenComponents()
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func excludeWeekendValueChanged(_ sender: UISwitch) {
        self.shareLinkModel.excludeWeekEnds = sender.isOn
    }
    
    @IBAction func removeInviteeCLicked(_ sender: UIButton) {
        self.buttonRemoveInvitee.isHidden = true
        self.imageViewSideArrowInvitee.isHidden = false
        self.shareLinkModel.invitees.removeAll()
        self.updateInviteesUI()
    }
    
    @IBAction func removeRemindeMeCLicked(_ sender: UIButton) {
        self.buttonRemoveReminder.isHidden = true
        self.imageReminderSideArrow.isHidden = false
        self.shareLinkModel.remindValue = nil
        self.updateRemindMeTitle()
    }
    
    
    @IBAction func toggleCalendarClicked(_ sender: UIButton) {
        self.resetAllButton(except: sender)
        sender.isSelected = !sender.isSelected
        self.viewDatePicker.isHidden = !sender.isSelected
        if !self.viewDatePicker.isHidden, let stringDate = sender.titleLabel?.text {
            self.dayDatePicker.selectRow(self.dayDatePicker.selectedDate(date: stringDate.toDate(withFormat: DateFormatters.DDHMMMMHYYYY) ?? Date()), inComponent: 0, animated: true)
        }
    }
    
    @IBAction func inviteUsersClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toInviteeUserLink, sender: nil)
    }
    
    @IBAction func geoLocationButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.goToMap, sender: nil)
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if self.validateMandatoryFields() {
            self.confirmingSaveForPastDate { (statusFlag) in
                if statusFlag {
                    self.saveShareLinkToServerUsingNetwork()
                }
            }
        }
    }
    
    @IBAction func descriptionButtonClicked(_ sender: UIButton) {
        self.textViewDescription.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
        case is UserCalendarListSelectionViewController:
            let calanderDropDownListViewController = segue.destination as! UserCalendarListSelectionViewController
            calanderDropDownListViewController.delegate = self
            calanderDropDownListViewController.isFromEvent = .eventCalendar
            calanderDropDownListViewController.selectedCalendars = self.shareLinkModel.calendars
        case is AddInviteeShareLinkViewController:
            let assignViewController = segue.destination as! AddInviteeShareLinkViewController
            assignViewController.addInviteeShareLinkDelegate = self
            if let assignee = self.shareLinkModel.invitees.first {
                assignViewController.selectedUser = AssignUser(calendarUser: CalendarUser(assignee))
            }
        case is CommonMapViewController:
            let commonMapViewController = segue.destination as! CommonMapViewController
            commonMapViewController.delegate = self
        case is EventReminderViewController:
            let eventReminderViewController = segue.destination as! EventReminderViewController
            eventReminderViewController.startDate = Date().nearestHalfHour()
            eventReminderViewController.toDoReminder = ReminderModel(self.shareLinkModel.remindValue, from: .event, isAllDay: false)
            eventReminderViewController.delegate = self
        case is ShareLinkTimeRangeViewController:
            let timeSlotViewController =  segue.destination as? ShareLinkTimeRangeViewController
            timeSlotViewController?.delegate = self
            timeSlotViewController?.durationInSeconds = self.shareLinkModel.duration.readDurationInSeconds()
            timeSlotViewController?.startingTime = self.shareLinkModel.startRangeTime
            let endDuration = self.shareLinkModel.endRangeTime.timeIntervalSince1970 - self.shareLinkModel.endRangeTime.initialHour().timeIntervalSince1970
            timeSlotViewController?.endingTime = self.shareLinkModel.startRangeTime.initialHour().addingTimeInterval(endDuration)
        case is AddDurationViewController:
            let addDurationViewController =  segue.destination as? AddDurationViewController
            addDurationViewController?.delegate = self
            addDurationViewController?.durationModel = DurationModel(with: self.shareLinkModel.duration)
        case is AddEventTagViewController:
            let addEventTagViewController = segue.destination as! AddEventTagViewController
            addEventTagViewController.tags = self.shareLinkModel.tags
            addEventTagViewController.textToPredict = self.shareLinkModel.createTextForPrediction()
            addEventTagViewController.defaultTags = self.shareLinkModel.getDefaultTags().map({ PredictionTag(with: $0) })
            addEventTagViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
