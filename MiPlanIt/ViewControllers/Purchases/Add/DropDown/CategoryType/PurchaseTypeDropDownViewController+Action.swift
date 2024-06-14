//
//  PurchaseTypeDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
extension PurchaseTypeDropDownViewController {
 
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.receipts, type: .eReceipt, isNeedImage: true, imageName: FileNames.purchasereceipticon), DropDownItem(name: Strings.bills, type: .eBill, isNeedImage: true, imageName: FileNames.purchasebillDicon)]
    }
}
