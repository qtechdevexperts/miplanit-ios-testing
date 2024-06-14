//
//  DashBoardViewController+Search.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension DashBoardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
