//
//  DataExtension.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 01/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension Data {
    
    func saveDataWithURL(_ url: String) {
        PINRemoteImageManager.shared().cache.setObjectOnDisk(self, forKey: url)
    }
}
