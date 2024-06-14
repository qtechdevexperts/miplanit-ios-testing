//
//  BubblePictureCellConfigFile.swift
//  Pods
//
//  Created by Kevin Belter on 1/2/17.
//
//

import UIKit

public struct BPCellConfigFile {
    
    var imageType: BPImageType?
    var title: String
    var name: String
    var imageUrl: String
    var status: UserStatus
    var respondStatus: RespondStatus
    var eventColor: String?
    public init(_ imageType: BPImageType? = nil, imageUrl: String, title: String, name: String, status: UserStatus = .eDefault, respondStatus: RespondStatus = .eDefault, eventColor: String? = nil) {
        self.imageType = imageType
        self.imageUrl = imageUrl
        self.title = title
        self.status = status
        self.name = name
        self.respondStatus = respondStatus
        self.eventColor = eventColor
        if name == "Note" || name == "Tees"{
            print("asd")
        }
    }
}
