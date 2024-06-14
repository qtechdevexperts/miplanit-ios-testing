//
//  AddCalendarViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddCalendarViewController {
    
    func createServiceToAddNewCalendar() {
        self.buttonSave.startAnimation()
        CalendarService().addEditNewCalendar(self.calendar, callback: { response, error in
            if let result = response {
                self.createServiceToUploadCalendarImages(planItCalendar: result)
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createServiceToUploadCalendarImages(planItCalendar: PlanItCalendar) {
        let fileName = String(Date().millisecondsSince1970) + Extensions.png
        guard let user = Session.shared.readUser(), let image = self.imageViewCalendarImage.image, let data = image.jpegData(compressionQuality: 0.5) else {
            self.showSuccessAlertOfCalendar(planItCalendar: planItCalendar)
            return
        }
        CalendarService().uploadCalendarImages(planItCalendar, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName, by: user) { (result, error) in
            if result {
                self.showSuccessAlertOfCalendar(planItCalendar: planItCalendar)
            }
            else {
                self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    //MARK: - Tick Animation
                    self.showAlertWithAction(message: Message.calendarImageUploadFailed, title: Message.error, items: [Message.ok], callback: { _ in
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.addCalendarViewController(self, createdNewCalendar: planItCalendar)
                    })
                }
            }
        }
    }
    
    func showSuccessAlertOfCalendar(planItCalendar: PlanItCalendar) {
        self.buttonSave.clearButtonTitleForAnimation()
        self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
            //MARK: - Tick Animation
            self.buttonSave.showTickAnimation { (result) in
                self.navigationController?.popViewController(animated: true)
                self.delegate?.addCalendarViewController(self, createdNewCalendar: planItCalendar)
            }
        }
    }
}
