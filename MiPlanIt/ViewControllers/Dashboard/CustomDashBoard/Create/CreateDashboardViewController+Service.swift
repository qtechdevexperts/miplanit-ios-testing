//
//  CreateDashboardViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension CreateDashboardViewController {
    
    func createWebServiceToCreateDashboard(onImageSave: Bool = false) {
        onImageSave ? self.buttonUploadProfilePic.startAnimation() : self.buttonDone.startAnimation()
        DashboardService().addDashboard(self.dashboardModel) { (response, error) in
            if let planItDashboard = response {
                self.dashboardModel.savePlanItDashboard(planItDashboard)
                if self.buttonUploadProfilePic.isSelected {
                    self.createServiceToUploadDashboardImages()
                }
                else {
                    self.buttonDone.clearButtonTitleForAnimation()
                    self.buttonDone.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                        self.buttonDone.showTickAnimation(borderOnly: true) { (result) in
                            self.imageViewDashboardPic.pinImageFromURL(URL(string: self.dashboardModel.userDashboardImage), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
                            self.delegate?.createDashboardViewController(self, updatedDashBord: self.dashboardModel)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonDone.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createServiceToUploadDashboardImages(onlyImage: Bool = false) {
        let fileName = String(Date().millisecondsSince1970) + Extensions.png
        guard let _ = Session.shared.readUser(), let image = self.imageViewDashboardPic.image, let data = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        if onlyImage {
            self.buttonUploadProfilePic.isHidden = false
            self.buttonUploadProfilePic.startAnimation()
        }
        DashboardService().updateDashboardPic(self.dashboardModel, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName) { (result, error) in
            if result {
                if onlyImage {
                    self.buttonUploadProfilePic.clearButtonTitleForAnimation()
                    self.buttonUploadProfilePic.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                        self.buttonUploadProfilePic.showTickAnimation { (result) in
                            self.buttonUploadProfilePic.isSelected = false
                            self.buttonUploadProfilePic.isHidden = true
                            self.delegate?.createDashboardViewController(self, updatedDashBord: self.dashboardModel)
                        }
                    }
                }
                else {
                    self.buttonDone.clearButtonTitleForAnimation()
                    self.buttonDone.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                        self.buttonDone.showTickAnimation(borderOnly: true) { (result) in
                            self.delegate?.createDashboardViewController(self, updatedDashBord: self.dashboardModel)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonUploadProfilePic.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
}
