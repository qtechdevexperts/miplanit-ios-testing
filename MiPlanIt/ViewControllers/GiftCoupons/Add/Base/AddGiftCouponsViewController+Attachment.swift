//
//  AddGiftCouponsViewController+Attachment.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

extension AddGiftCouponsViewController: AttachFileDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            self.giftCouponModel.addAttachement(UserAttachment(with: compressedImage, type: .giftCoupon, ownerId: self.giftCouponModel.ownerUserId))
            self.showAttachmentsCount()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

