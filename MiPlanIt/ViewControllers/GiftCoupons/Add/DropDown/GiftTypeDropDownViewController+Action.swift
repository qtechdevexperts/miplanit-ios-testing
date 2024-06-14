//
//  GiftTypeDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension GiftTypeDropDownViewController {
 
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.giftcards, type: .eCouponTypeGift, isNeedImage: true, imageName: FileNames.giftCardDDicon), DropDownItem(name: Strings.giftcoupons, type: .eCouponTypeCoupon, isNeedImage: true, imageName: FileNames.giftcouponDDicon)]
    }
}
