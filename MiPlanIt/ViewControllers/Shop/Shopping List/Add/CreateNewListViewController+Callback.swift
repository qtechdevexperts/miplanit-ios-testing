//
//  CreateNewListViewController+Callback.swift
//  MiPlanIt
//
//  Created by fsadsmin on 24/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension CreateNewListViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.returnKeyType = ((textView.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && text.isEmpty) ? .default : .done
        textView.reloadInputViews()
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.shop.shopListName = textView.text
    }
}

extension CreateNewListViewController: CalendarImageViewDelegate {
    
    func calendarImageView(_ calendarImageView: CalendarImageView, selectedImage: UIImage?) {
        self.arrayShoppingListImageViews.forEach { (view) in
            view.resetSelection()
        }
        calendarImageView.setSelection()
        self.imageViewShoppingListImage.image = selectedImage
    }
}

extension CreateNewListViewController: ProfileMediaDropDownViewControllerDelegate {
    
    func profileMediaDropDownViewController(_ controller: ProfileMediaDropDownViewController, selectedOption: DropDownItem) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        switch selectedOption.dropDownType {
        case .eCamera:
            self.capturePhotoFromDevice()
        case .eGallery:
            self.captureMediaFromDeviceLibrary()
        default: break
        }
    }
}

extension CreateNewListViewController: CalendarColorViewDelegate {
    
    func calendarColorView(_ calendarColorView: CalendarColorView, selectedColorCode: String) {
        self.updateBGWithColor(selectedColorCode)
    }
}
