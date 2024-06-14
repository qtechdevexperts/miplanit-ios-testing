//
//  ProfileBaseViewController+Country.swift
//  MiPlanIt
//
//  Created by Arun on 24/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ProfileBaseViewController: CountrySelectionViewControllerDelegate {
    
    func countrySelectionViewController(_ viewController: CountrySelectionViewController, selectedCode: String) {
        self.buttonCountryCode.setTitle("+\(selectedCode)", for: .normal)
    }
}
