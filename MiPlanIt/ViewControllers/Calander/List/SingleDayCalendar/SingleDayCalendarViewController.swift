//
//  SingleDayCalendarViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 28/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol SingleDayCalendarViewControllerDelegate: AnyObject {
    func singleDayCalendarViewController(_ viewcontroller: SingleDayCalendarViewController, didSelect event: Event)
    func singleDayCalendarViewController(_ viewcontroller: SingleDayCalendarViewController, createEventOn date: Date?)
}

class SingleDayCalendarViewController: UIViewController {
    
    var events: [Event] = []
    var calendarType: MiPlanItCalendarType = .myCalendar
    var eventUsers: [OtherUser] = []
    var selectedDate = Date()
    var containsMiPlanItCalendarWithOtherUser: Bool = false
    weak var delegate: SingleDayCalendarViewControllerDelegate?
    var selectedCalanders: [PlanItCalendar] = []
    lazy var allAvailableCalendars: [PlanItCalendar] = {
        return DatabasePlanItCalendar().readAllPlanitCalendars()
    }()

    @IBOutlet weak var viewCalendarList: UsersListView!
    @IBOutlet weak var viewCalendarListContainer: UIView!
    @IBOutlet weak var viewCalanderHolder: UIView!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var labelTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialiseCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initialiseUIComponents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calendarView.reloadFrame(self.calendarView.frame)
    }

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
