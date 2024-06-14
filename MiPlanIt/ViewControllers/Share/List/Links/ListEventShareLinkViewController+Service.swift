//
//  ListEventShareLinkViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ListEventShareLinkViewController {
    
    func createServiceToUsersShareList(onPullToRefresh flag: Bool = false) {
        guard let user = Session.shared.readUser(), SocialManager.default.isNetworkReachable() else {
            if flag {
                self.stopPullToRefresh()
            }
            return
        }
        if !flag {
            self.buttonProcessingLoader.startAnimation()
        }
        self.apiCallInProgress = true
        CalendarService().fetchUsersShareLinkServerData(user) { [weak self] (result, serviceDetection, error) in
            guard let self = self else { return }
            self.apiCallInProgress = false
            flag ? self.stopPullToRefresh() : self.buttonProcessingLoader.stopAnimation()
            result ? self.readAllUserShareLinkList() : self.showErrorMessage(error ?? Message.unknownError)
        }
    }
    
    func createServiceToDeleteUsersShareList(shareLink: PlanItShareLink, cell: EventShareLinkTableViewCell?) {
        cell?.startGradientAnimation()
        CalendarService().deleteEventShareLink(shareLink) { (response, error) in
            cell?.stopGradientAnimation()
            if let _ = response {
                self.removeSharedLinkList(shareLink)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
}
