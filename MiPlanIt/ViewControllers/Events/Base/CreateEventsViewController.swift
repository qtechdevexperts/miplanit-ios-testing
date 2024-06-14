//
//  CreateEventsViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol CreateEventsViewControllerDelegate: AnyObject {
    func createEventsViewController(_ viewController: CreateEventsViewController, addedEvents: [Any], deletedChilds: [String]?, toCalendars calendars: [UserCalendarVisibility])
}

class CreateEventsViewController: UIViewController {
   
    var selectedData: Date?
    var selectedDateTime: Date?
    var selectedCalendar: PlanItCalendar?
    var eventModel = MiPlanItEvent()
    var arrayAllTimeSlotEvent: [TimeSlotEvent] = []
    weak var delegate: CreateEventsViewControllerDelegate?
    
    // MARK:- IBOutlet
    @IBOutlet weak var viewSingleDay: UIView!
    @IBOutlet weak var viewAllDay: UIView!
    @IBOutlet var buttonToggleCalendar: [UIButton]!
    @IBOutlet weak var buttonTimeSlot: UIButton!
    @IBOutlet weak var buttonSingleDate: UIButton!
    @IBOutlet weak var buttonRepeat: UIButton!
    @IBOutlet weak var buttonRemind: UIButton!
    @IBOutlet weak var textFieldLocation: FloatingTextField!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBOutlet weak var viewInviteeList: UsersListView!
    @IBOutlet weak var buttonCalendar: UIButton!
    @IBOutlet weak var buttonNotifyCalendar: UIButton!
    @IBOutlet weak var buttonInvitees: UIButton!
    @IBOutlet weak var buttonInviteesArrow: UIImageView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet var lottieAnimationView2: LottieAnimationView!
    @IBOutlet weak var switchIsTravelling: UISwitch!
    @IBOutlet weak var switchIsAllDay: UISwitch!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var textFieldEventName: FloatingTextField!
    @IBOutlet weak var buttonSaveEvent: ProcessingButton!
    @IBOutlet weak var buttonAllDayStartDate: UIButton!
    @IBOutlet weak var buttonAllDatEndDate: UIButton!
    @IBOutlet weak var labelEventTitle: UILabel!
    @IBOutlet weak var labelEventTagCount: UILabel!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelBillDateError: UILabel!
    @IBOutlet weak var viewBillBorder: UIView!
    @IBOutlet weak var viewRepeat: UIView!
    @IBOutlet weak var constraintViewRepeatHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonRemoveReminder: UIButton!
    @IBOutlet weak var imageReminderSideArrow: UIImageView!
    @IBOutlet weak var imageViewCalendarSideArrow: UIImageView!
    @IBOutlet weak var buttonTag: UIButton?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dayDatePicker: DayDatePicker!
    
    var titles: [String] = [] {
        didSet {
            self.eventModel.tags = titles
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setIntialValuesForScreenComponents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.textFieldEventName.paddingValue = (self.textFieldEventName.superview?.frame.width ?? 25)*0.061
        self.buttonTimeSlot.layoutIfNeeded()
    }
    
    @IBAction func locationValueChanged(_ sender: UITextField) {
        if let locationText = sender.text, locationText.isEmpty {
            self.eventModel.resetLocation()
        }
    }
    
    @IBAction func geoLocationButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.goToMap, sender: nil)
    }
    
    @IBAction func isTravellingChanged(_ sender: UISwitch) {
        self.view.endEditing(true)
        self.eventModel.isTravelling = sender.isOn
    }
    
    @IBAction func allDayChanged(_ sender: UISwitch) {
        self.resetAllButton()
        self.viewSingleDay.isHidden = sender.isOn
        self.viewAllDay.isHidden = !sender.isOn
        self.viewDatePicker.isHidden = true
        self.eventModel.isAllday = sender.isOn
        self.eventModel.remindValue?.updateIsAllDay(with: sender.isOn)
        self.updateRemindMeTitle()
        self.updateAllDateWithButton()
    }
    
    @IBAction func toggleCalendarClicked(_ sender: UIButton) {
        self.resetAllButton(except: sender)
        sender.isSelected = !sender.isSelected
        self.viewDatePicker.isHidden = !sender.isSelected
        if !self.viewDatePicker.isHidden, let stringDate = sender.titleLabel?.text {
            self.dayDatePicker.selectRow(self.dayDatePicker.selectedDate(date: stringDate.toDate(withFormat: DateFormatters.DDHMMMMHYYYY) ?? Date()), inComponent: 0, animated: true)
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if self.validateMandatoryFields() {
            if self.eventModel.editType == .allEventInTheSeries {
                self.showAlertWithAction(message: Message.eventEditAllEventInThisScreen, title: Message.editSeries, items: [Message.save, Message.cancel], callback: { index in
                    if index == 0 { self.saveEventToServerUsingNetwotk() }
                })
            }
            else {
                self.saveEventToServerUsingNetwotk()
            }
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.datePickerValueUpdate(sender: sender)
        
    }
    
    @IBAction func descriptionButtonClicked(_ sender: UIButton) {
        self.textViewDescription.becomeFirstResponder()
    }
    
    @IBAction func tagButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func removeReminderClicked(_ sender: UIButton) {
        self.eventModel.remindValue = nil
        self.updateRemindMeTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is TimeSlotViewController:
            let timeSlotViewController =  segue.destination as? TimeSlotViewController
            timeSlotViewController?.delegate = self
            timeSlotViewController?.invitees = self.eventModel.invitees
            timeSlotViewController?.startingTime = self.eventModel.startDate
            timeSlotViewController?.endingTime = self.eventModel.endDate
            timeSlotViewController?.editEventId = eventModel.eventId
        case is RepeatViewController:
            let repeatViewController = segue.destination as? RepeatViewController
            repeatViewController?.delegate = self
            repeatViewController?.orginalRecurrenceRule = self.eventModel.readRecurrence()
            repeatViewController?.myPlanItEvent = self.eventModel
            repeatViewController?.eventStartDate = eventModel.startDate
        case is UserCalendarListSelectionViewController:
            let calanderDropDownListViewController = segue.destination as! UserCalendarListSelectionViewController
            calanderDropDownListViewController.delegate = self
            calanderDropDownListViewController.isFromEvent = .eventCalendar
            calanderDropDownListViewController.selectedCalendars = self.eventModel.calendars
            calanderDropDownListViewController.switchOnlyMiCalendars = self.eventModel.isEdit() && self.isUpdatingMiCalendarEvent()
        case is NotifyCalendarListViewController:
            let calanderDropDownListViewController = segue.destination as! NotifyCalendarListViewController
            calanderDropDownListViewController.delegate = self
            calanderDropDownListViewController.isFromEvent = .notifyCalendar
            calanderDropDownListViewController.selectedCalendars = self.eventModel.notifycalendars
            calanderDropDownListViewController.selectedCalendarForRemoval = self.eventModel.calendars
        case is AddInviteesViewController:
            let addInviteesViewController = segue.destination as! AddInviteesViewController
            addInviteesViewController.delegate = self
            addInviteesViewController.selectedInvitees = self.eventModel.invitees
        case is AddEventTagViewController:
            let addEventTagViewController = segue.destination as! AddEventTagViewController
            addEventTagViewController.tags = self.eventModel.tags
            addEventTagViewController.textToPredict = self.eventModel.createTextForPrediction()
            addEventTagViewController.defaultTags = self.eventModel.getDefaultTags().map({ PredictionTag(with: $0) })
            addEventTagViewController.delegate = self
        case is CommonMapViewController:
            let commonMapViewController = segue.destination as! CommonMapViewController
            commonMapViewController.delegate = self
            commonMapViewController.selectedLocation = (self.eventModel.location, self.eventModel.placeLatitude, self.eventModel.placeLongitude)
        case is EventReminderViewController:
            let eventReminderViewController = segue.destination as! EventReminderViewController
            eventReminderViewController.startDate = self.eventModel.startDate
            eventReminderViewController.toDoReminder = ReminderModel(self.eventModel.remindValue, from: .event, isAllDay: self.eventModel.isAllday)
            eventReminderViewController.delegate = self
        case is EventHelpScreenViewController:
            self.scrollView.setContentOffset(.zero, animated: false)
        default: break
        }
    }
}
