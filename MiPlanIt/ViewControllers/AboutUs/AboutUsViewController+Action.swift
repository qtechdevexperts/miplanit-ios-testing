//
//  AboutUsViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 04/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AboutUsViewController {

    func initialiseUIComponents() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.lblVersion.text = "Version \(version ?? "1.0")"
    }
}
