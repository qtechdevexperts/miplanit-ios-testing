//
//  OTPTextField.swift
//  MiPlanIt
//
//  Created by Arun on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol OTPTextFieldDelegate: UITextFieldDelegate {
    func textField(_ textField: OTPTextField, with otp: String)
}

class OTPTextField: FloatingTextField {
    
    weak var otpDelegate: OTPTextFieldDelegate?
    
    override func awakeFromNib() {
        self.otpDelegate = self.delegate as? OTPTextFieldDelegate
        super.awakeFromNib()
    }

    override func deleteBackward() {
        super.deleteBackward()
        _ = self.delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: Strings.empty)
    }
    
    override var text: String? {
        didSet {
            if let value = text, value.count > 1 {
                self.otpDelegate?.textField(self, with: value)
            }
        }
    }
}
