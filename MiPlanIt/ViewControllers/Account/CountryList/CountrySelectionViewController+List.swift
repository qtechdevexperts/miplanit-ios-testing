//
//  CountrySelectionViewController+List.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension CountrySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cell, for: indexPath) as! CountryCodeCell
        cell.configure(data: self.showingCountries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.countrySelectionViewController(self, selectedCode: self.showingCountries[indexPath.row].phone)
        self.navigationController?.popViewController(animated: true)
    }
}
