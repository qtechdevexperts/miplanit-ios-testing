//
//  DataStorageViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension DataStorageViewController {
    
    func initilizeView() {
        self.progressView.progress = 0.5
        self.progressView.layer.cornerRadius = 7.5
        self.progressView.clipsToBounds = true
        self.progressView.layer.sublayers![1].cornerRadius = 7.5
        self.progressView.subviews[1].clipsToBounds = true
        self.setStorageData()
        if SocialManager.default.isNetworkReachable() {
            self.callWebServiceFindStorage()
        }
    }
    
    func setStorageData() {
        self.labelTotalSpace.text = (self.userStorage?.readTotalSpace() ?? "0.0 MB")
        self.labelUsedSpace.text = (self.userStorage?.readUsedSpace() ?? "0.0 GB")
        if let storage = self.userStorage {
            self.progressView.progress = Float(storage.usedSpace/storage.totalSpace)
        }
        else {
            self.progressView.progress = 0.0
        }
        self.updateProgressColor()
    }
    
    func updateProgressColor() {
        if self.progressView.progress >= 1.0 {
            self.progressView.progressTintColor = UIColor.red
        }
        else if self.progressView.progress >= 0.75 {
            self.progressView.progressTintColor = UIColor.orange
        }
        else {
            self.progressView.progressTintColor = UIColor.init(red: 58/255, green: 184/255, blue: 208/255, alpha: 1.0)
        }
    }
}
