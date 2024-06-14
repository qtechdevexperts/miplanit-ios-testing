//
//  ProfileBaseViewController+Image.swift
//  MiPlanIt
//
//  Created by MS Nischal on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

extension ProfileBaseViewController: ProfileMediaDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

    // MARK: - Image Capture
    func capturePhotoFromDevice() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)  {
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.videoDenied])
            }
            else {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
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
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.galleryDenied])
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) || UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.dismiss(animated: true, completion: nil)
            let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            let orientationFixedImage = image.fixOrientation()
            self.imageViewProfilePic.image = orientationFixedImage
            self.buttonUploadProfilePic.isSelected = true
            self.buttonUploadProfilePic.isHidden = false
            self.buttonUploadProfilePic.setTitle(Strings.upload, color: .white)
            self.uploadPicToServerUsingNetwotk()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
