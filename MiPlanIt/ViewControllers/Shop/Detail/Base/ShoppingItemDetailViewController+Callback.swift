//
//  ShoppingItemDetailViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices
import IQKeyboardManagerSwift

extension ShoppingItemDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension ShoppingItemDetailViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        self.shopItemDetailModel.itemName = self.textViewItemName.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


extension ShoppingItemDetailViewController: CategoryListSectionViewControllerDelegate {
    
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, add userCategory: CategoryData) {
        self.delegate?.shoppingItemDetailViewController(self, onAddUserCategory: userCategory)
    }
    
    
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, selectedMainCategory: CategoryData?, selectedSubCategory: CategoryData?, userCategory: CategoryData?) {
        if let master = selectedMainCategory {
            self.shopItemDetailModel.masterCategoryId = master.categoryId
            self.shopItemDetailModel.categoryName = master.categoryName
            self.labelCategoryName.text = master.categoryName
            self.shopItemDetailModel.masterSubCategoryId = 0
            self.shopItemDetailModel.userCategoryId = 0
            self.shopItemDetailModel.appCategoryId = Strings.empty
        }
        if let subCategory = selectedSubCategory {
            self.shopItemDetailModel.masterSubCategoryId = subCategory.categoryId
            self.shopItemDetailModel.categoryName = subCategory.categoryName
            self.labelCategoryName.text = subCategory.categoryName
            self.shopItemDetailModel.userCategoryId = 0
            self.shopItemDetailModel.appCategoryId = Strings.empty
        }
        if let userCategory = userCategory {
            self.shopItemDetailModel.appCategoryId = userCategory.categoryAppId
            self.shopItemDetailModel.userCategoryId = userCategory.categoryId
            self.shopItemDetailModel.categoryName = userCategory.categoryName
            self.labelCategoryName.text = userCategory.categoryName
            self.shopItemDetailModel.masterCategoryId = 0
            self.shopItemDetailModel.masterSubCategoryId = 0
        }
    }
    
}


extension ShoppingItemDetailViewController: AddShoppingTagViewControllerDelegate {
    
    func addShoppingTagViewController(_ viewController: AddShoppingTagViewController, updated tags: [String]) {
        self.shopItemDetailModel.tags = tags
        self.showTagsCount()
    }
}

extension ShoppingItemDetailViewController: AttachFileDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    func attachFileDropDownViewController(_ controller: AttachFileDropDownViewController, selectedOption: DropDownItem) {
        switch selectedOption.dropDownType {
        case .eCamera:
            self.capturePhotoFromDevice()
        case .eGallery:
            self.captureMediaFromDeviceLibrary()
        case .eViewAttachment:
            self.performSegue(withIdentifier: Segues.toAttachments, sender: self)
        default: break
        }
    }
    
    // MARK: - Image Capture
    func capturePhotoFromDevice() {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)  {
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.videoDenied])
            }
            else {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        else {
            //Alert:- failed to access camera
        }
    }
    
    func captureMediaFromDeviceLibrary() {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)  {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.galleryDenied])
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let compressedImage = image.fixOrientation().jpegData(compressionQuality: 0.5) {
            let ownerIdValue = self.shopItemDetailModel.planItShopList?.createdBy?.readValueOfUserId()
            self.shopItemDetailModel.addAttachement(UserAttachment(with: compressedImage, type: .shopping, ownerId: ownerIdValue))
            self.showAttachmentsCount()
            self.updateAttachmentCollection()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension ShoppingItemDetailViewController: AttachmentListViewControllerDelegate {
    
    
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment]) {
        self.shopItemDetailModel.attachments = items
        self.showAttachmentsCount()
        self.updateAttachmentCollection()
    }
}


extension ShoppingItemDetailViewController: ReminderBaseViewControllerDelegate {
    
    func reminderBaseViewController(_ reminderBaseViewController: ReminderBaseViewController, reminderValue: ReminderModel) {
        self.shopItemDetailModel.remindValue = reminderValue
        self.updateRemindMeTitle()
    }
    
    func reminderBaseViewControllerBackClicked(_ reminderBaseViewController: ReminderBaseViewController) {
        
    }
}


extension ShoppingItemDetailViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.updateDueDateChanged(selectedDate.initialHour())
    }
}
