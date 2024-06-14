//
//  CreateEventsViewController+CalendarDropDown.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: GoogleMapViewControllerDelegate {
    
    func googleMapViewController(_ googleMapViewController: GoogleMapViewController, selectedLocation: String) {
        self.textFieldLocation.text = self.eventModel.setLocation(selectedLocation)
    }
}

extension CreateEventsViewController: CalendarListSelectionViewControllerDelegate {
    
    func calendarListSelectionViewController(_ controller: UserCalendarListSelectionViewController, selectedOptions: [UserCalendarVisibility]) {
        self.eventModel.calendars = selectedOptions
        self.eventModel.removeCalendarFromNotifyCalendars(selectedOptions)
        self.buttonNotifyCalendar.setTitle(self.eventModel.notifycalendars.isEmpty ? Strings.empty : "\(self.eventModel.notifycalendars.count) Selected", for: .normal)
        self.buttonCalendar.setTitle(self.eventModel.readMainCalendar()?.readValueOfOrginalCalendarName(), for: .normal)
        self.callServiceToFetchCalendarUserDetails()
    }
}

extension CreateEventsViewController: NotifyCalendarListSelectionViewControllerDelegate {
    
    func calendarListSelectionViewController(_ controller: NotifyCalendarListViewController, selectedOptions: [UserCalendarVisibility]) {
        self.eventModel.notifycalendars = selectedOptions
        self.buttonNotifyCalendar.setTitle(selectedOptions.isEmpty ? Strings.empty : "\(selectedOptions.count) Selected", for: .normal)
    }
}


extension CreateEventsViewController: CommonMapViewControllerDelegate {
    
    func commonMapViewController(_ commonMapViewController: CommonMapViewController, selectedLocation: String, latitude: Double?, longitude: Double?) {
        self.textFieldLocation.text = self.eventModel.setLocationFromMap(locationName: selectedLocation, latitude: latitude, longitude: longitude)
    }
}

