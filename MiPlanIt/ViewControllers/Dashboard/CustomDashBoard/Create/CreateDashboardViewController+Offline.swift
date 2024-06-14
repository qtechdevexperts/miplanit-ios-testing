//
//  CreateDashboardViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CreateDashboardViewController {
    
    func saveDashboardToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToCreateDashboard()
        }
        else {
            let data = self.buttonUploadProfilePic.isSelected ? self.imageViewDashboardPic.image?.jpegData(compressionQuality: 0.5) : nil
            DatabasePlanItDashboard().insertDashboardOfflineData(self.dashboardModel, imageData: data)
            self.imageViewDashboardPic.pinImageFromURL(URL(string: self.dashboardModel.userDashboardImage), placeholderImage: nil)
            self.delegate?.createDashboardViewController(self, updatedDashBord: self.dashboardModel)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveDashboardPicToServerUsingNetwotk(onlyImage imageFlag: Bool = false) {
        if SocialManager.default.isNetworkReachable() {
            self.createServiceToUploadDashboardImages(onlyImage: imageFlag)
        }
        else {
            let data = self.buttonUploadProfilePic.isSelected ? self.imageViewDashboardPic.image?.jpegData(compressionQuality: 0.5) : nil
            if let imageData = data {
                self.dashboardModel.userDashboardImageData = imageData
                DatabasePlanItDashboard().insertDashboardOfflineData(self.dashboardModel, imageData: imageData)
                self.imageViewDashboardPic.image = UIImage(data: imageData)
                self.delegate?.createDashboardViewController(self, updatedDashBord: self.dashboardModel)
            }
        }
    }
}
