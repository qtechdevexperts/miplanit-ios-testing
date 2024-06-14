//
//  EventAddTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol EventAddTagCollectionViewCellDelegate: class {
    func eventAddTagCollectionViewCell(_ cell: EventAddTagCollectionViewCell, addedNewTag tag: String)
    func eventAddTagCollectionViewCell(_ cell: EventAddTagCollectionViewCell, checkExisting tag: String) -> Bool
}

class EventAddTagCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: EventAddTagCollectionViewCellDelegate?
    
    // MARK:- IBOutlet
    @IBOutlet weak var textfieldTag: UITextField!
    @IBOutlet weak var buttonAddTag: UIButton!
    
    // MARK:- IBAction
    @IBAction func addTagButtonClicked(_ sender: UIButton) {
        self.buttonAddTag.isHidden = true
        self.textfieldTag.isHidden = false
        self.textfieldTag.becomeFirstResponder()
    }
    
    func configureCell(vc: EventAddTagCollectionViewCellDelegate) {
        self.delegate = vc
    }
    
    func saveTag(){
        if let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines), tag != Strings.empty {
            self.delegate?.eventAddTagCollectionViewCell(self, addedNewTag: tag)
        }
    }
    
    func isNewTag() -> Bool {
        guard let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !(self.delegate?.eventAddTagCollectionViewCell(self, checkExisting: tag) ?? true)
    }
    
    func resetAddTagField() {
        self.buttonAddTag.isHidden = false
        self.textfieldTag.isHidden = true
        self.textfieldTag.text = nil
    }
    
}

 
extension EventAddTagCollectionViewCell: UITextFieldDelegate {
    
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
