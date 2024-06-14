//
//  DataStorageViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension DataStorageViewController {
    
    func callWebServiceFindStorage() {
        guard let user = Session.shared.readUser() else { return }
        self.buttonLoader.startAnimation()
        UserService().getUserDataStorage(user) { (response, error) in
            self.buttonLoader.stopAnimation()
            if let dataStorage = response {
                self.userStorage = dataStorage
                self.setStorageData()
            }
        }
    }
}
