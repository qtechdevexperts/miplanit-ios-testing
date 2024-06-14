//
//  PaymentTypeViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PaymentTypeViewController {
    
    func initialiseUIComponents() {
        self.imageTickMarkCard.isHidden = self.selectedPayment != 1
        self.imageTickMarkCash.isHidden = self.selectedPayment != 2
        self.imageTickMarkOther.isHidden = self.selectedPayment != 3
        self.buttonAddCard.isHidden = self.selectedPayment != 1
        self.viewSavedCards.isHidden = self.savedCards.count == 0 || self.selectedPayment != 1
        self.viewAddCards.isHidden = self.savedCards.count == 0 || self.selectedPayment != 1
        self.viewAddDesc.isHidden = self.selectedPayment != 3
        self.txtDescription.text = self.paymentDescription
    }
    
    func readAllPaymentCards() {
        self.savedCards = DatabasePlanItUserPayment().readUserPaymentCards().map({ return UserPaymentOption(with: $0, selected: $0.cardNumber == self.selctedCard?.cardNumber) })
    }
    
    func updatePaymentType() {
        if !self.imageTickMarkCash.isHidden {
            self.dismiss(animated: true) {
                self.delegate?.paymentTypeViewController(self, selectedPayement: 2, with: nil)
            }
        }
        else if !self.imageTickMarkCard.isHidden{
            if self.viewNewCard.isHidden {
                if let selectedCard = self.savedCards.filter({ return $0.isSelected }).first {
                    self.dismiss(animated: true) {
                        self.delegate?.paymentTypeViewController(self, selectedPayement: 1, with: PurchaseCard(with: selectedCard.paymentCard.readCardName(), number: selectedCard.paymentCard.readCardNumber()))
                    }
                }
                else {
                    //MARK: - Validation Error
                    self.showAlert(message: Message.paymentInformationMissing, title: Message.warning)
                }
            }
            else {
                guard self.validateNewCardDetails() else { return }
                self.dismiss(animated: true) {
                    DatabasePlanItUserPayment().insertNewPaymentCard(self.txtCardName.text!, number: self.txtCardNumber.text!)
                    self.delegate?.paymentTypeViewController(self, selectedPayement: 1, with: PurchaseCard(with: self.txtCardName.text!, number: self.txtCardNumber.text!))
                }
            }
        }
        else if !self.imageTickMarkOther.isHidden {
            self.dismiss(animated: true) {
                self.delegate?.paymentTypeViewController(self, selectedPayement: 3, with: self.txtDescription.text ?? Strings.empty)
            }
        }
    }
    
    func selectPaymentTypeWith(_ sender: UIButton) {
        self.imageTickMarkCash.isHidden = (sender.tag != 0)
        self.imageTickMarkCard.isHidden = (sender.tag != 1)
        self.imageTickMarkOther.isHidden = (sender.tag != 2)
        self.buttonAddCard.isHidden = (sender.tag != 1)
        self.viewSavedCards.isHidden = self.savedCards.count == 0 || sender.tag != 1
        self.viewAddCards.isHidden = self.savedCards.count == 0 || sender.tag != 1
        self.viewAddDesc.isHidden = sender.tag != 2
        if sender.tag != 1 {
            self.buttonAddCard.isSelected = false
            self.viewNewCard.isHidden = true
        }
        if self.imageTickMarkCard.isHidden {
            self.savedCards.forEach({$0.isSelected = false})
            self.tableViewCards.reloadData()
        }
    }
}

