//
//  AssignToDoViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/05/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension AssignToDoViewController {
    
    @objc func createServiceToCheckEmailNotExist(_ username: String?, completion: @escaping (Bool, String?)->()) {
        completion(true, nil)
    }
}
