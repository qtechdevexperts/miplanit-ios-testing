//
//  TimeSlotViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol TimeSlotViewControllerDelegate: AnyObject {
    
    func timeSlotViewControllerDelegateOnSave(_ timeSlotViewController: TimeSlotViewController, from startDate: Date, to endDate: Date)
}

class TimeSlotViewController: UIViewController {
    
    enum TimeSelection {
        case start, end
    }
    var userResizableView: RKUserResizableView!
    var lastEditedView:RKUserResizableView? = nil
    var currentlyEditingView:RKUserResizableView? = nil
    var scrollContentSize: CGSize!
    var eventTimeView: EventTimeView?
    var startingTime: Date = Date()
    var endingTime: Date = Date()
    var invitees: [OtherUser] = []
    weak var delegate: TimeSlotViewControllerDelegate?
    var otherUserEventTimeViews: [OtherUserEventTimeView] = []
    var currentUserEventTimeViews: [CurrentUserEventTimeView] = []
    
    var userTimeSlotEvent: [TimeSlotEvent] = []
    var editEventId: String?
    var operationCount: Int = 0 {
        didSet {
            if self.operationCount == 0 && self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            else if self.operationCount > 0 && !self.activityIndicator.isAnimating {
                self.activityIndicator.startAnimating()
            }
        }
    }
    var currentTimePickerSelection: TimeSelection = .start {
        didSet {
            switch self.currentTimePickerSelection {
            case .start:
                self.buttonStartTime?.isSelected = true
                self.butttonEndTime?.isSelected = false
            case .end:
                self.buttonStartTime?.isSelected = false
                self.butttonEndTime?.isSelected = true
            }
        }
    }
    
    //MARK:- IBOutlet
    @IBOutlet weak var viewScrollViewContainer: UIView!
    @IBOutlet weak var scrollView: TimeSlotScrollView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var buttonDate: UIButton!
    @IBOutlet weak var viewInvitees: UIView!
    @IBOutlet weak var viewSeperator: UIView!
    @IBOutlet weak var viewFSCalendar: FSCalendar!
    @IBOutlet weak var viewUsersList: UsersListView!
    @IBOutlet var viewContainer: TimeSlotViewContainer!
    @IBOutlet weak var stackViewAllDayEvent: UIStackView!
    @IBOutlet weak var labelAllDayCaption: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewTimePicker: UIView!
    @IBOutlet weak var buttonStartTime: UIButton?
    @IBOutlet weak var butttonEndTime: UIButton?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonToggleTimePicker: UIButton!
    @IBOutlet weak var viewStartSelection: UIView!
    @IBOutlet weak var viewEndSelection: UIView!
    @IBOutlet weak var imageViewTogglePicker: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        // Do any additional setup after loading the view.
    }
    
    deinit {
        UserStatusOperator.default.cancelAllOperations()
        UserEventOperator.default.cancelAllOperations()
        OtherUserEventOperator.default.cancelAllOperations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setData()
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.setResizableViewFrame(initially: true)
        self.scrollContentSize = self.scrollView.contentSize
        self.scollToEvent()
        super.viewDidAppear(animated)
    }
    
    //MARK:- IBAction
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.delegate?.timeSlotViewControllerDelegateOnSave(self, from: self.startingTime, to: self.endingTime)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dateButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewSeperator.backgroundColor = (!sender.isSelected && self.invitees.isEmpty ? UIColor.clear : UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1))
        self.viewFSCalendar.isHidden = !sender.isSelected
        self.viewInvitees.isHidden = sender.isSelected ? true : self.invitees.isEmpty
    }
    
    @IBAction func startTimeButtonClicked(_ sender: UIButton) {
        self.currentTimePickerSelection = .start
        self.viewStartSelection.isHidden = false
        self.viewEndSelection.isHidden = true
        self.datePicker.minimumDate = self.startingTime.initialHour()
        self.datePicker.maximumDate = self.startingTime.initialHour().adding(days: 1).adding(minutes: -15)
        self.datePicker.setDate(self.startingTime, animated: false)
    }
    
    @IBAction func endTimeButtonClicked(_ sender: UIButton) {
        self.currentTimePickerSelection = .end
        self.viewStartSelection.isHidden = true
        self.viewEndSelection.isHidden = false
        self.datePicker.minimumDate = self.startingTime.initialHour().adding(minutes: 15)
        self.datePicker.maximumDate = self.startingTime.initialHour().adding(days: 1).adding(minutes: -1)
        self.datePicker.setDate(self.endingTime, animated: false)
    }
    
    @IBAction func toggleTimePicker(_ sender: UIButton) {
        self.buttonToggleTimePicker.isSelected = !self.buttonToggleTimePicker.isSelected
        self.imageViewTogglePicker.image = self.buttonToggleTimePicker.isSelected ? #imageLiteral(resourceName: "time-slot-icon") : #imageLiteral(resourceName: "time-picker-icon")
        self.viewTimePicker.isHidden = !self.buttonToggleTimePicker.isSelected
        self.datePicker.setDate(self.startingTime, animated: false)
    }
    
    @IBAction func timeValueChanged(_ sender: UIDatePicker) {
        switch self.currentTimePickerSelection {
        case .start:
            self.updateStartTime(sender.date)
        case .end:
            self.updateEndTime(sender.date)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is InviteesStatusViewController:
            let inviteesStatusViewController = segue.destination as! InviteesStatusViewController
            inviteesStatusViewController.invitees = self.invitees
        case is TimePickerViewController:
            let timePickerViewController = segue.destination as! TimePickerViewController
            timePickerViewController.startingTime = self.startingTime
            timePickerViewController.endingTime = self.endingTime
            timePickerViewController.delegate = self
        default: break
        }
        
    }
}


