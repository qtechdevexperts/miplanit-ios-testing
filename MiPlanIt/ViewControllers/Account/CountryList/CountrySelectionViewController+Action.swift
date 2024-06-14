//
//  CountrySelectionViewController+Action.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CountrySelectionViewController {
    
    func readCountries() -> [Country] {
        if let path = Bundle.main.path(forResource: FileNames.country, ofType: Extensions.fileTypePlist) {
            if let countries = NSArray(contentsOfFile: path) as? [[String: String]] {
                return countries.map({ return Country(data: $0) })
            }
        }
        return []
    }
}

