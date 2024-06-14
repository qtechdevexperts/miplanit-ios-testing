//
//  PurchaseAddTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PurchaseAddTagCollectionViewCellDelegate: class {
    func purchaseAddTagCollectionViewCell(_ cell: PurchaseAddTagCollectionViewCell, addedNewTag tag: String)
    func purchaseAddTagCollectionViewCell(_ cell: PurchaseAddTagCollectionViewCell, checkExisting tag: String) -> Bool
}

class PurchaseAddTagCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PurchaseAddTagCollectionViewCellDelegate?
    
    // MARK:- IBOutlet
    @IBOutlet weak var textfieldTag: UITextField!
    @IBOutlet weak var buttonAddTag: UIButton!
    
    // MARK:- IBAction
    @IBAction func addTagButtonClicked(_ sender: UIButton) {
        self.buttonAddTag.isHidden = true
        self.textfieldTag.isHidden = false
        self.textfieldTag.becomeFirstResponder()
    }
    
    func configureCell(vc: PurchaseAddTagCollectionViewCellDelegate) {
        self.delegate = vc
    }
    
    func saveTag(){
        if let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines), tag != Strings.empty {
            self.delegate?.purchaseAddTagCollectionViewCell(self, addedNewTag: tag)
        }
    }
    
    func isNewTag() -> Bool {
        guard let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !(self.delegate?.purchaseAddTagCollectionViewCell(self, checkExisting: tag) ?? true)
    }
    
    func resetAddTagField() {
        self.buttonAddTag.isHidden = false
        self.textfieldTag.isHidden = true
        self.textfieldTag.text = nil
    }
    
}

 
extension PurchaseAddTagCollectionViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.isNewTag() {
            self.saveTag()
        }
        self.resetAddTagField()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if self.isNewTag() {
            self.saveTag()
        }
        self.resetAddTagField()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
