//
//  AttachmentListViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AttachmentListViewController {
    
    func initialiseUIComponents() {
        self.viewNoItem.isHidden = !self.attachments.isEmpty
        self.buttonAttachment.isHidden = self.activityType == .none
    }
}
