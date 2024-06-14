//
//  PurchaseAttachment.swift
//  MiPlanIt
//
//  Created by Arun on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserAttachment: Comparable {
    
    var data: Data!
    let file: String
    var createdDate = Date()
    var type: AttachmentType
    var identifier = Strings.empty
    var url: String = Strings.empty
    var itemOwnerId: String?

    init(with data: Data, type: AttachmentType, ownerId: String?) {
        self.data = data
        self.type = type
        self.file = "attachement" + "_" + "\(Date().stringFromDate(format: DateFormatters.EEEMMMDDYYYYHHSSA))"
        self.itemOwnerId = ownerId
    }
    
    init(with attachment: PlanItUserAttachment, type: AttachmentType, ownerId: String?) {
        self.type = type
        self.url = attachment.readFilePath()
        self.file = attachment.readFileName()
        self.identifier = attachment.readAttachmentId()
        self.createdDate = attachment.readCreatedDate()
        self.data = attachment.data
        self.itemOwnerId = ownerId
    }
    
    static func ==(lhs: UserAttachment, rhs: UserAttachment) -> Bool {
        return lhs.file == rhs.file
    }
    
    static func < (lhs: UserAttachment, rhs: UserAttachment) -> Bool {
        return lhs.file == rhs.file
    }
}
