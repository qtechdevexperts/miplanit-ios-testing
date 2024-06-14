//
//  TableViewExtension.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView {

    static var reuseIdentifier: String { get }

}

extension ReusableView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

}

extension UITableViewCell: ReusableView {}


extension UITableView {

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }

        return cell
    }
    
    override open func reloadInputViews() {
        super.reloadInputViews()
        self.tableFooterView = UIView()
    }
 

}
