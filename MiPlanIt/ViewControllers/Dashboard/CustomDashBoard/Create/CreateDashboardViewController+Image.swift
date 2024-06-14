//
//  CreateDashboardViewController+Image.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

extension CreateDashboardViewController: ProfileMediaDropDownViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            self.imageViewDashboardPic.image = orientationFixedImage
            self.buttonUploadProfilePic.setTitle(Strings.upload, color: .white)
            self.buttonUploadProfilePic.isSelected = true
            if self.dashboardModel.planItDashBoard != nil {
                self.saveDashboardPicToServerUsingNetwotk(onlyImage: true)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
