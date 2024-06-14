//
//  Country.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class Country: NSObject {
    
    let name: String
    let code: String
    let phone: String
    let icon: String
    
    init(name: String, code: String, phone: String, icon: String) {
        self.name = name
        self.code = code
        self.phone = phone
        self.icon = icon
    }
    
    convenience init(data: [String: String]) {
        self.init(name: data["name"]!, code: data["code"]!, phone: data["phone"]!, icon: data["icon"]!)
    }
}
