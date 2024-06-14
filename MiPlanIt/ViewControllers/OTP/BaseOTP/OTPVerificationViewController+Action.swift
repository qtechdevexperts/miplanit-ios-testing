//
//  OTPVerificationViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension OTPVerificationViewController {
    
    func manageScreenHeaderTitle() {
        self.labelHeaderCaption.text = self.countryCode.isEmpty ? Message.otpSentToMail : Message.otpSentToPhone
    }
    
    func containsAnyEmptyOTPField() -> Bool {
        return self.textFieldOTP.filter({ return $0.text?.isEmpty ?? false }).isEmpty
    }
    
    func getOTPCode() -> String {
        return self.textFieldOTP.compactMap({$0.text}).joined()
    }
}
