//
//  PlanItEventAttachment+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension PlanItEventAttachment {

    func readFileUrl() -> String { return self.fileUrl ?? Strings.empty }
    func readTitle() -> String { return self.title ?? Strings.empty }
    func readIconLink() -> String { return self.iconLink ?? Strings.empty }
}
