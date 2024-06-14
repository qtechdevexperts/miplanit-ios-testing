//
//  HelpViewController+mail.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MessageUI

extension HelpViewController : MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["support@miplanit.com"])
            mailComposeViewController.setSubject("Feedback")
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            self.showAlert(message: Message.errorMailSend, title: Message.error)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
//        if result == .sent {
//            self.showAlert(message: Message.feedbackSentSuccessfully, title: Message.success)
//        }
    }
}
