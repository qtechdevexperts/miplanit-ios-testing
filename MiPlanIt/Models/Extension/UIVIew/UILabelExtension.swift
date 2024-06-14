//
//  UILabelExtension.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func validateTextWithType(_ type: ValidatorType) throws -> Bool {
        let value = self.text ?? Strings.empty
        let validator = VaildatorFactory.validatorFor(type: type)
        return try validator.validated(value)
    }
}
