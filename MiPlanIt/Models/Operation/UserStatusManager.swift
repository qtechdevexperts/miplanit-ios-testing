//
//  UserStatusManager.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol UserStatusManagerDelegate: class {
    func userStatusManager(_ manager: UserStatusManager, getWithStatus otherUsers: [OtherUser])
}

class UserStatusManager: Operation {
    
    var startTime: Date = Date()
    var endTime: Date = Date()
    var otherUsers: [OtherUser] = []
    weak var delegate: UserStatusManagerDelegate?
    
    override func main() {
        self.otherUsers.forEach { (invitees) in
            _ = invitees.checkUserStatus(from: self.startTime, to: self.endTime)
        }
        self.delegate?.userStatusManager(self, getWithStatus: self.otherUsers)
    }
    
    
}

class UserStatusOperator {
    
    static let `default` = UserStatusOperator()
    
    let userStatusOperationQueue = OperationQueue()
    
    init() {
        self.userStatusOperationQueue.maxConcurrentOperationCount = 1
    }
    
    func suspendAllOperations() {
        self.userStatusOperationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        self.userStatusOperationQueue.isSuspended = false
    }
    
    func cancelAllOperations() {
        self.userStatusOperationQueue.cancelAllOperations()
    }
    
    func getUserStatus(of users: [OtherUser], startDateTime: Date, endDateTime: Date, delegate: UserStatusManagerDelegate?) {
        let userStatusManager = UserStatusManager()
        userStatusManager.startTime = startDateTime
        userStatusManager.endTime = endDateTime
        userStatusManager.otherUsers = users
        userStatusManager.delegate = delegate
        self.userStatusOperationQueue.addOperation(userStatusManager)
    }
}
