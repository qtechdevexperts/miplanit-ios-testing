//
//  PaddingTextField.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class PaddingTextField: UITextField {
    
    @IBInspectable var isPaddingEnabled: Bool = true
    
    @IBInspectable var paddingValue: CGFloat = 10
    
    @IBInspectable var rightPaddingValue: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rightView = UIView()
    }
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if self.isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            self.insertText(text)
        }
        return success
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.isPaddingEnabled ? CGRect(x: bounds.minX + paddingValue, y: bounds.minY, width: bounds.width - (paddingValue + rightPaddingValue) , height: bounds.height) : bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.isPaddingEnabled ? CGRect(x: bounds.minX + paddingValue, y: bounds.minY, width: bounds.width - (paddingValue + rightPaddingValue), height: bounds.height) : bounds
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.isPaddingEnabled ? CGRect(x: bounds.minX + paddingValue, y: bounds.minY, width: bounds.width - (paddingValue + rightPaddingValue), height: bounds.height) : bounds
    }
}
