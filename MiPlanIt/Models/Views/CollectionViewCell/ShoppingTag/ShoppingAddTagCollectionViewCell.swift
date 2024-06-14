//
//  GiftCouponAddTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ActivityAddTagCollectionViewCellDelegate: class {
    func activityAddTagCollectionViewCell(_ cell: ActivityAddTagCollectionViewCell, addedNewTag tag: String)
    func activityAddTagCollectionViewCell(_ cell: ActivityAddTagCollectionViewCell, checkExisting tag: String) -> Bool
}

class ActivityAddTagCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ActivityAddTagCollectionViewCellDelegate?
    
    // MARK:- IBOutlet
    @IBOutlet weak var textfieldTag: SpeechTextField!
    @IBOutlet weak var buttonAddTag: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    // MARK:- IBAction
    @IBAction func addTagButtonClicked(_ sender: UIButton) {
        self.buttonAddTag.isHidden = true
        self.textfieldTag.isHidden = false
        self.textfieldTag.becomeFirstResponder()
    }
    
    func configureCell(vc: ActivityAddTagCollectionViewCellDelegate) {
        self.delegate = vc
        self.textfieldTag.speechTextFieldDelegate = self
        if self.buttonAddTag.isHidden {
            DispatchQueue.main.async {
                self.textfieldTag.becomeFirstResponder()
            }
        }
    }
    
    func saveTag(){
        if let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines), tag != Strings.empty {
        }
    }
    
    func isNewTag() -> Bool {
        guard let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !(self.delegate?.activityAddTagCollectionViewCell(self, checkExisting: tag) ?? true)
    }
    
    func isNewSelectionTag(_ tag: String) -> Bool {
        return !(self.delegate?.activityAddTagCollectionViewCell(self, checkExisting: tag) ?? true)
    }
    
    func resetAddTagField() {
        self.buttonAddTag.isHidden = false
        self.textfieldTag.isHidden = true
        self.textfieldTag.text = nil
    }
}

 
extension ActivityAddTagCollectionViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.isNewTag() {
            textField.resignFirstResponder()
            if let tag = self.textfieldTag.text?.trimmingCharacters(in: .whitespacesAndNewlines), tag != Strings.empty {
                textField.text = Strings.empty
                self.delegate?.activityAddTagCollectionViewCell(self, addedNewTag: tag)
            }
            else {
                self.resetAddTagField()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        self.textfieldTag.filterTag(by: String(newString))
        return newString.length <= maxLength
    }
}


extension ActivityAddTagCollectionViewCell: SpeechTextFieldDelegate {
    
    func speechTextField(_ speechTextField: SpeechTextField, valueChanged text: String) {
        
    }
    
    func speechTextField(_ speechTextField: SpeechTextField, valueAdded text: String) {
        if !text.isEmpty && self.isNewSelectionTag(text) {
            self.buttonAddTag.isHidden = false
            self.textfieldTag.resignFirstResponder()
            self.textfieldTag.text = Strings.empty
            self.delegate?.activityAddTagCollectionViewCell(self, addedNewTag: text)
        }
    }
    
    
}
