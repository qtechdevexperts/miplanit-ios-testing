//
//  CustomDashBoardViewController+Actions.swift
//  MiPlanIt
//
//  Created by fsadmin on 06/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardViewController {
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateGreetingText), name: UIApplication.willEnterForegroundNotification, object: self)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: self)
    }
    
    func initialDateRangeSetUp() {
        self.endDateOfMonth = Date().initialHour().adding(years: 1)
        self.initializePulse()
    }
    
    func initializePulse() {
        self.pulseRoundStartView?.layer.superlayer?.insertSublayer(self.pulsator, below: self.pulseRoundStartView?.layer)
        self.pulsator.numPulse = 5
        self.pulsator.radius = 240
        self.pulsator.animationDuration = 5
    }
    
    func updateDashboardProfilesViews() {
        self.updateGreetingText()
        if let user = Session.shared.readUser() {
            self.imageViewCenterUser.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
            self.labelUserName.text = user.readValueOfName()
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressMainUser))
        self.buttonMainUser.addGestureRecognizer(longGesture)
    }
    
    @objc func updateGreetingText() {
        self.labelUserGreeting.text = "Good " + Date().getDayPart()
    }
    
    @objc func longPressMainUser(gesture: UIGestureRecognizer) {
        self.performSegue(withIdentifier: Segues.showPopUpDashboardDetail, sender: nil)
    }
    
    func refreshCustomDashboardProfiles() {
        self.availableDashboardProfiles = DatabasePlanItDashboard().readAllDashboards().map({ CustomDashboardProfile(with: $0) })
        self.isAllDashboardServiceCompleted = true
        self.setUsersOnView()
    }
    
    func updateMainCount() {
        let totalCount = self.totalItemsCount
        let count = totalCount > 99 ? "99+" : "\(totalCount)"
        var section = ""
        switch self.dashboardSection {
        case .today:
            section = "for Today"
        case .tomorrow:
            section = "for Tomorrow"
        case .week:
            section = "for this Week"
        default:
            section = "Upcoming"
        }
        DispatchQueue.main.async {
            self.labelitemsCountMain.text = count
            self.labelitems.text = "You have " + count + " items " + section
        }
    }
    
    func hideAllUserDataIfNeeded(force: Bool = true) {
        if force || !self.isReachedToDoLimitUserType(self.dashboardSection) || !self.isReachedEventLimitUserType(self.dashboardSection) || !self.isReachedGiftUserType(self.dashboardSection) || !self.isReachedShoppingLimitUserType(self.dashboardSection) || !self.isReachedPurchaseUserType(self.dashboardSection) || self.availableDashboardProfiles.count > self.profilesImageDownloadCount {
            guard !self.pulsator.isPulsating else { return }
            self.updateVisibilityOfUserData(with: false)
        }
    }
    
    func showAllUserDataIfNeeded() {
        if self.isReachedToDoLimitUserType(self.dashboardSection) && self.isReachedEventLimitUserType(self.dashboardSection) && self.isReachedGiftUserType(self.dashboardSection) && self.isReachedShoppingLimitUserType(self.dashboardSection) && self.isReachedPurchaseUserType(self.dashboardSection) && self.availableDashboardProfiles.count <= self.profilesImageDownloadCount && self.isAllDashboardServiceCompleted {
            guard self.pulsator.isPulsating else { return }
            self.updateVisibilityOfUserData(with: true)
        }
    }
    
    func updateVisibilityOfUserData(with status: Bool) {
        self.labelitemsCountMain.isHidden = !status || self.totalItemsCount == 0
        self.imageViewCountMainCircle.isHidden = !status || self.totalItemsCount == 0
        self.labelitems.isHidden = !status
        self.imageViewCenterUser.isHidden = !status
        self.viewTwo.isHidden = !status
        self.viewThree.isHidden = !status
        self.viewFour.isHidden = !status
        self.viewFive.isHidden = !status
        self.pulseRoundStartView?.isHidden = status
        status ? self.pulsator.stop() : self.pulsator.start()
        self.viewUsersCircle.subviews.forEach { (view) in
            if let profileView = view as? CustomDashboardView {
                profileView.isHidden = !status
            }
        }
    }
    
    func refreshDashboardDataWithTileSelection(_ type: DashBoardTitle) {
        switch type {
        case .event:
            self.readEventsOf(self.dashboardSection)
        case .toDo:
            self.readToDos(self.dashboardSection)
        case .purchase:
            self.readPurchases(self.dashboardSection)
        case .giftCard:
            self.readGiftCards(self.dashboardSection)
        case .shopping:
            self.readShopping(self.dashboardSection)
        }
    }
    
    func removeCustomeDashboardView(_ view: UIView) {
        for eachSubView in view.subviews {
            if let dashboardView = eachSubView as? CustomDashboardView {
                dashboardView.removeFromSuperview()
            }
        }
    }
    
    func updateExistingDashboardProfile(_ customDashboard: CustomDashboardProfile, onUpdate: Bool = false) {
        if let customDashboardView = self.customDashboardView.first(where: { return $0.dashboardProfile == customDashboard }) {
            if onUpdate {
                customDashboardView.updateNotificationCount(by: customDashboard.notificationCount, updateImage: customDashboard.planItDashboard.readImage())
            }
            else {
                customDashboardView.updateNotificationCount(by: customDashboard.updateCustomeDashboardViewCount(events: self.visibleEvents, todos: self.visibleTodos, purchases: self.visiblePurchases, gifts: self.visibleGifts, shoppings: self.visibleShopings))
            }
        }
    }
    
    func removeAllCustomDashboardView() {
        self.profilesImageDownloadCount = 0
        for eachView in self.customDashboardView {
            eachView.removeFromSuperview()
        }
        self.customDashboardView.removeAll()
        self.view.layoutIfNeeded()
    }
    
    func setUsersOnView() {
        self.removeAllCustomDashboardView()
        self.removeCustomeDashboardView(self.viewTwo)
        self.removeCustomeDashboardView(self.viewThree)
        self.removeCustomeDashboardView(self.viewFour)
        
        if self.availableDashboardProfiles.isEmpty {
            self.showAllUserDataIfNeeded()
            return
        }
        let views = [self.viewTwo,self.viewThree,self.viewFour]
        var maxElementsInCircle = self.availableDashboardProfiles.count / 3 + (self.availableDashboardProfiles.count % 3 == 0 ? 0 : 1)
        maxElementsInCircle = maxElementsInCircle == 0 ? 1 : maxElementsInCircle
        
        var dashboardProfilesCounter: Int = 0
        for (index,singleView) in views.enumerated() {
            var points = self.getCirclePoints(centerPoint: CGPoint(x: singleView!.center.x - singleView!.frame.origin.x, y: singleView!.center.y - singleView!.frame.origin.y), radius: (singleView?.frame.size.width)! / 2, n: maxElementsInCircle, index: index)
            if points.count > maxElementsInCircle {
                points.removeLast()
            }
            let balance = self.availableDashboardProfiles.count - (maxElementsInCircle * (index + 1))
            if balance < 0  {
                points.removeLast(abs(balance))
            }
            for singlepoint in points {
                let customDashoardView = CustomDashboardView(frame: CGRect.init(origin: singlepoint, size: CGSize(width: 82, height: 82)), dashboard: self.availableDashboardProfiles[dashboardProfilesCounter], delegate: self)
                customDashoardView.frame = CGRect(x: singleView!.frame.minX+customDashoardView.frame.minX, y: singleView!.frame.minY+customDashoardView.frame.minY, width: 82, height: 82)
                customDashoardView.isHidden = true
                self.viewUsersCircle.addSubview(customDashoardView)
                customDashoardView.downloadImage(profileImage:  self.availableDashboardProfiles[dashboardProfilesCounter].planItDashboard.readImage())
                customDashoardView.updateNotificationCount(by: self.availableDashboardProfiles[dashboardProfilesCounter].updateCustomeDashboardViewCount(events: self.visibleEvents, todos: self.visibleTodos, purchases: self.visiblePurchases, gifts: self.visibleGifts, shoppings: self.visibleShopings))
                self.customDashboardView.append(customDashoardView)
                dashboardProfilesCounter += 1
            }
            if dashboardProfilesCounter >= (self.availableDashboardProfiles.count) {
                break
            }
        }
    }

    func updateDashboardProfileViewsWithSpecificType(_ type: DashBoardTitle) {
        DispatchQueue.main.async {
            switch type {
            case .event:
                self.customDashboardView.forEach { (view) in
                    if let customDashboardProfile = view.dashboardProfile {
                        view.updateNotificationCount(by: customDashboardProfile.updateCustomeDashboardEvent(self.visibleEvents))
                    }
                }
            case .toDo:
                self.customDashboardView.forEach { (view) in
                    if let customDashboardProfile = view.dashboardProfile {
                        view.updateNotificationCount(by: customDashboardProfile.updateCustomeDashboardTodos(self.visibleTodos))
                    }
                }
            case .purchase:
                self.customDashboardView.forEach { (view) in
                    if let customDashboardProfile = view.dashboardProfile {
                        view.updateNotificationCount(by: customDashboardProfile.updateCustomeDashboardPurchases(self.visiblePurchases))
                    }
                }
            case .giftCard:
                self.customDashboardView.forEach { (view) in
                    if let customDashboardProfile = view.dashboardProfile {
                        view.updateNotificationCount(by: customDashboardProfile.updateCustomeDashboardGifts(self.visibleGifts))
                    }
                }
            case .shopping:
                self.customDashboardView.forEach { (view) in
                    if let customDashboardProfile = view.dashboardProfile {
                        view.updateNotificationCount(by: customDashboardProfile.updateCustomeDashboardShopings(self.visibleShopings))
                    }
                }
            }
        }
    }
    
    func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int, index: Int)->[CGPoint] {
        let fromValue = n > 1 ? (0 + (360 / n * index) / 2 ) : (0 + (120 * index) )
        let toValue = n > 1 ? (360 + (360 / n * index) / 2 ) : (360 + (120 * index) )
        let result: [CGPoint] = stride(from: fromValue, to: toValue , by: Int(360.0 / Double(n) )).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing) - 41
            let y = point.y + radius * sin(bearing) - 41
            return CGPoint(x: x, y: y)
        }
        return result
    }
    
    func updateDashboardView(_ planItDashBoard: PlanItDashboard) {
        if let customDasboard = self.availableDashboardProfiles.first(where: { return $0.planItDashboard == planItDashBoard }) {
            self.updateExistingDashboardProfile(customDasboard)
        }
        else {
            self.hideAllUserDataIfNeeded()
            self.refreshCustomDashboardProfiles()
        }
    }
}
