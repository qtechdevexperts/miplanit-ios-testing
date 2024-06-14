//
//  ViewEventViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ViewEventViewControllerDelegate: AnyObject {
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [PlanItEvent], deletedChilds: [String]?)
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [OtherUserEvent], deletedChilds: [String]?)
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [PlanItEvent], deletedChilds: [String]?, withType type: RecursiveEditOption)
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [OtherUserEvent], deletedChilds: [String]?, withType type: RecursiveEditOption)
}

class ViewEventViewController: UIViewController {
    
    var modifiedEvents: [Any] = []
    var dateEvent: DateSpecificEvent!
    var eventPlanOtherObject: Any!
    var deletedEvents: [String]?
    weak var delegate: ViewEventViewControllerDelegate?

    @IBOutlet weak var viewDetailSIPConference: ViewDetailsDataValue!
    @IBOutlet weak var viewDetailPhoneConference: ViewDetailsDataValue!
    @IBOutlet weak var viewDetailsVideoConference: ViewDetailsDataValue!
    @IBOutlet weak var viewDetailsLocation: ViewDetailsDataValue!
    @IBOutlet weak var viewDetailsEventDate: ViewDetailsEventDate!
    @IBOutlet weak var viewDetailsInvitees: ViewDetailsInvitees!
    @IBOutlet weak var viewDetailsCalendarData: ViewDetailsCalendarData!
    @IBOutlet weak var viewDetailsRemindMe: ViewDetailsDataValue!
    @IBOutlet weak var viewDetailsDescription: ViewDetailsDescription!
    @IBOutlet weak var buttonDelete: ProcessingButton!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonTag: ProcessingButton!
    @IBOutlet weak var descriptionArrow: UIImageView!
    @IBOutlet weak var viewTopColorHeader: UIView!
    @IBOutlet weak var viewTopNonColorHeader: UIView!
    @IBOutlet weak var viewTopBarGradient: UIView!
    
    @IBOutlet weak var labelPresentTagCount: UILabel!
    @IBOutlet weak var buttonPresentTag: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !self.modifiedEvents.isEmpty, let event = self.modifiedEvents as? [PlanItEvent] {
            self.delegate?.viewEventViewController(self, update: event, deletedChilds: self.deletedEvents)
        }
        else if !self.modifiedEvents.isEmpty, let otherUserEvent = self.eventPlanOtherObject as? [OtherUserEvent] {
            self.delegate?.viewEventViewController(self, update: otherUserEvent, deletedChilds: self.deletedEvents)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        var location: String = Strings.empty
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            location = planItEvent.readLocation()
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            location = otherUserEvent.location
        }
        let locatinData = location.split(separator: Strings.locationSeperator)
        if locatinData.count > 2, let locationName = locatinData.first, let latitude = Double(locatinData[1]), let longitude = Double(locatinData[2]) {
            self.openMapForPlace(latitude: latitude, longitude: longitude, name: String(locationName))
        }
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        self.readRecurrentActionForEvent(isEdit:true, callBack: { result, type in
            guard result else { return }
            let finalType = type == .allFutureEvent && self.dateEvent.startDate == self.readEventCreatedDate() ? .allEventInTheSeries : type
            let event = self.createEventModelForEditEvent(withType: finalType)
            self.performSegue(withIdentifier: Segues.toEditEvent, sender: event)
        })
    }
    
    @IBAction func showOtherDetailsView(_ sender: UIButton) {
        guard self.isHTMLLinkAvailable() else { return }
        if self.navigationController == nil {
            self.performSegue(withIdentifier: Segues.presentWebView, sender: nil)
        }
        else {
            self.performSegue(withIdentifier: Segues.toWebView, sender: nil)
        }
    }
    
    @IBAction func dismissButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tagButtonClicked(_ sender: UIButton) {
        if self.navigationController == nil {
            self.performSegue(withIdentifier: Segues.presetToTagVC, sender: nil)
        }
        else {
            self.performSegue(withIdentifier: Segues.pushToTagVC, sender: nil)
        }
    }
    
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        var planItEventObject: PlanItEvent?
        if let event = eventPlanOtherObject as? PlanItEvent {
            planItEventObject = event
        }
        if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent, let eventId = Double(otherUserEvent.eventId) {
            planItEventObject = DatabasePlanItEvent().readPlanItEventsWith(eventId)
        }
        guard let planItEvent = planItEventObject else { return }
        if DatabasePlanItSocialUser().checkUserExistsInMiPlaniT(planItEvent.readSocialCalendarEventCreatorEmail()) || (planItEvent.createdBy?.readValueOfUserId() == Session.shared.readUserId() && !planItEvent.isSocialEvent) {
            self.readRecurrentActionForEvent(isEdit:false, callBack: { result, type in
                guard result else { return }
                let finalType = type == .allFutureEvent && self.dateEvent.startDate == self.readEventCreatedDate() ? .allEventInTheSeries : type
                self.saveDeleteEventToServerUsingNetwotk(planItEvent, type: finalType)
            })
        }
        else {
            self.readRecurrentCancelActionForEvent(callBack: { result, type in
                guard result else { return }
                let finalType = type == .allFutureEvent && self.dateEvent.startDate == self.readEventCreatedDate() ? .allEventInTheSeries : type
                self.saveCancelEventToServerUsingNetwotk(planItEvent, type: finalType)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is CreateEventsViewController:
            let createEventsViewController =  segue.destination as! CreateEventsViewController
            createEventsViewController.delegate = self
            createEventsViewController.eventModel = sender as! MiPlanItEvent
        case is AddEventTagViewController:
            let addEventTagViewController = segue.destination as! AddEventTagViewController
            addEventTagViewController.tags = self.readAllTags()
            addEventTagViewController.delegate = self
            addEventTagViewController.canAddTag = true
            addEventTagViewController.textToPredict = self.createTextToPredict()
            addEventTagViewController.defaultTags = self.getDefaultTags().map({ PredictionTag(with: $0) })
        case is WebViewController:
            let webViewController = segue.destination as! WebViewController
            webViewController.htmlString = self.createStringForWebView()
        case is NotificationToDoTagViewController:
            let notificationToDoTagViewController = segue.destination as! NotificationToDoTagViewController
            notificationToDoTagViewController.tags = self.readAllTags()
        default:
            break
        }
    }
}
