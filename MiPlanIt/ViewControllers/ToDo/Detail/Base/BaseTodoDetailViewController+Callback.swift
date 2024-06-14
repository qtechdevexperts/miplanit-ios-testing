//
//  TodoDetailViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices
import IQKeyboardManagerSwift
import GrowingTextView

extension BaseTodoDetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.returnKeyType = ((textView.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && text.isEmpty) ? .default : ( textView == self.textViewNotes ? .default : .done)
        textView.reloadInputViews()
        if(text == "\n") && textView != self.textViewNotes {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.textFieldToDoName {
            self.toDoDetailModel.todoName = textView.text
        }
        else if textView == self.textViewNotes {
            self.toDoDetailModel.notes = textView.text
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.textViewNotes {
            self.noteLineHeight(onStart: true)
        }
    }
}

extension BaseTodoDetailViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
}

extension BaseTodoDetailViewController: ToDoRemindViewControllerDelegate {
    
    func toDoRemindViewController(_ controller: ToDoRemindViewController, selectedOption: DropDownItem) {
        self.labelRemindMe.text =  selectedOption.title
    }
}

extension BaseTodoDetailViewController: RepeatViewControllerDelegate {
    
    func repeatViewController(_ repeatViewController: RepeatViewController, recurrenceRule: String) {
        self.toDoDetailModel.recurrence = recurrenceRule
        self.setRepeatTitle(rule: recurrenceRule)
    }
}

extension BaseTodoDetailViewController: AddTaskTagViewControllerDelegate {
    
    func addTaskTagViewController(_ viewController: AddTaskTagViewController, updated tags: [String]) {
        self.toDoDetailModel.tags = tags
        self.showTagsCount()
    }
}


extension BaseTodoDetailViewController: AttachmentListViewControllerDelegate {
    
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment]) {
        self.toDoDetailModel.attachments = items
        self.showAttachmentsCount()
    }
}

extension BaseTodoDetailViewController: AssignToDoViewControllerDelegate {
    
    func assignToDoViewController(_ assignToDoViewController: AssignToDoViewController, selectedAssige: CalendarUser?, toDoItems: [PlanItTodo]) {
        self.buttonRemoveAssignee.isHidden = selectedAssige == nil
        guard let assignedUser = selectedAssige else {
            self.toDoDetailModel.assignee = []
            self.viewAssignUser.isHidden = true
            self.viewAssignLabel.isHidden = false
            return }
        self.viewAssignUser.isHidden = false
        self.viewAssignLabel.isHidden = true
        self.imageViewAssignUser.pinImageFromURL(URL(string: assignedUser.profile), placeholderImage: assignedUser.name.shortStringImage())
        self.labelAssigneName.text = assignedUser.name
        self.toDoDetailModel.assignee = [OtherUser(calendarUser: assignedUser)]
        self.imageViewUserStatus?.isHidden = true
        self.imageViewUserStatus?.image = nil
    }
}

extension BaseTodoDetailViewController: AttachFileDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            self.toDoDetailModel.addAttachement(UserAttachment(with: compressedImage, type: .task, ownerId: self.toDoDetailModel.categoryOwnerId))
            self.showAttachmentsCount()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension BaseTodoDetailViewController: NotificationToDoTagViewControllerDelegate {
    
    func notificationToDoTagViewController(_ viewController: NotificationToDoTagViewController, updated tags: [String]) {
        self.toDoDetailModel.tags = tags
        self.showTagsCount()
    }
    
}

extension BaseTodoDetailViewController: ReminderBaseViewControllerDelegate {
    
    func reminderBaseViewControllerBackClicked(_ reminderBaseViewController: ReminderBaseViewController) {
    }
    
    func reminderBaseViewController(_ reminderBaseViewController: ReminderBaseViewController, reminderValue: ReminderModel) {
        self.toDoDetailModel.remindValue = reminderValue
        self.updateRemindMeTitle()
    }
}


extension BaseTodoDetailViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.updateDueDateChange(selectedDate.initialHour())
    }
}
