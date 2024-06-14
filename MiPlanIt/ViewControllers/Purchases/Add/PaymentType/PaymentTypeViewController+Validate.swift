//
//  PaymentTypeViewController+Validate.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension PaymentTypeViewController {
    func validateNewCardDetails() -> Bool {
        self.view.endEditing(true)
        var paymentCardName = false
        var paymentCardNumber = false
        do {
            paymentCardName = try self.txtCardName.validateTextWithType(.username)
        } catch {
            self.txtCardName.showError(Message.cardNameIsRequired, animated: true)
        }
        do {
            paymentCardNumber = try self.txtCardNumber.validateTextWithType(.username)
        } catch {
            self.txtCardNumber.showError(Message.cardNumberIsRequired, animated: true)
        }
        return paymentCardName && paymentCardNumber
    }
}
