//
//  CurrencyCodeViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
extension CurrencyCodeViewController {
    func initializeUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        self.searchCurrencyUsingText(text: Strings.empty)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchCurrencyUsingText(text: String) {
        self.buttonClearSearch.isHidden = text.isEmpty
        guard !text.isEmpty else { self.searchDropDownItems = self.dropDownItems; return }
        self.searchDropDownItems = self.dropDownItems.filter({ return $0["code"]?.range(of: text, options: .caseInsensitive) != nil || $0["name"]?.range(of: text, options: .caseInsensitive) != nil
        })
    }
    
    func sendSelectedOption(_ currencySymbol: String) {
        self.delegate?.currencyCodeViewController(self, selectedOption: currencySymbol)
    }
    
}

extension CurrencyCodeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        self.searchCurrencyUsingText(text: currentText)
        return true
    }
}
