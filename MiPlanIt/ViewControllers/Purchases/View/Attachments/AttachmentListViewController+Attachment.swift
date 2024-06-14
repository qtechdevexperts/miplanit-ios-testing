//
//  AttachmentListViewController+Attachment.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

extension AttachmentListViewController: AttachListFileDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func attachListFileDropDownViewController(_ controller: AttachListFileDropDownViewController, selectedOption: DropDownItem) {
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
    
    // MARK: - Image Capture
    func capturePhotoFromDevice() {
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
            self.attachments.append(UserAttachment(with: compressedImage, type: self.activityType, ownerId: self.itemOwnerId))
            self.viewNoItem.isHidden = true
            self.tableViewAttachments.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AttachmentListViewController: AttachmentListTableViewCellDelegate {
    
    func attachmentListTableViewCell(_ cell: AttachmentListTableViewCell, removeAtIndexPath indexPath: IndexPath) {
        self.attachments.remove(at: indexPath.row)
        self.viewNoItem.isHidden = !self.attachments.isEmpty
        self.tableViewAttachments.reloadData()
    }
}

