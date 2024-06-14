//
//  DropDownItem.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit


class DropDownItem: NSObject {
    
    let title: String
    let image: String
    let isImageType: Bool
    let isEnabled: Bool
    var isSelected: Bool = false
    var id: String = Strings.empty
    var parentId: Double
    let dropDownType: DropDownOptionType
    var value: String = Strings.empty
    
    init(name: String, identifier: String = Strings.empty, parent: Double = 0, type: DropDownOptionType = .eNever, isNeedImage: Bool = false, itemEnabled: Bool = true, isSelected: Bool = false, imageName: String = Strings.empty, value: String = Strings.empty) {
        self.title = name
        self.id = identifier
        self.parentId = parent
        self.dropDownType = type
        self.image = imageName
        self.isEnabled = itemEnabled
        self.isImageType = isNeedImage
        self.value = value
        self.isSelected = isSelected
    }
}
