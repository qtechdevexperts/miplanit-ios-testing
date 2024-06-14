//
//  DashBoardViewController+Actions.swift
//  MiPlanIt
//
//  Created by Arun on 27/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension DashBoardViewController {
    
    func initialDateRangeSetUp() {
        self.endDateOfMonth = Date().initialHour().adding(years: 1)
    }
    
    func intialiseUIComponents() {
        self.viewCustomDashboards.delegate = self
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.showDefaultDashboardBasicDetails()
        self.viewDashBoardCardList.setupViews(delegate: self)
        self.pageControl.numberOfPages = self.isPhone_5_5c_5c_SE() ? 3 : 2
        self.pageControl.currentPage = 0
        self.updateDashboardProfilesViews()
        self.fetchAllCustomDashBoard()
        self.setRefreshController()
        self.calculateOverDueToDo()
    }
            
    func setRefreshController() {
        let refreshControl = self.scrollView.addRefreshControl(target: self,
                                                          action: #selector(doRefresh(_:)))
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "")
    }
    
    @objc func doRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        self.createWebServiceToCheckInApp()
    }

    
    func showDefaultDashboardBasicDetails() {
        if let customDefaultDashboard = self.customDashboard {
            if let imageData = customDefaultDashboard.dashboardImageData {
                self.imageViewProfilePic.image = UIImage(data: imageData)
            }
            else {
                self.imageViewProfilePic.pinImageFromURL(URL(string: customDefaultDashboard.readImageURL()), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
            }
            self.buttonDashboardName.setTitle(customDefaultDashboard.readDashboardName(), for: .normal)
            self.viewCustomDashboards.isCustomDashboard = true
        }
        else if let user = Session.shared.readUser() {
            self.imageViewProfilePic.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
            self.buttonDashboardName.setTitle("My Dashboard", for: .normal)
            self.viewCustomDashboards.isCustomDashboard = false
        }
    }
    
    func setHorizontalFlowLayout() {
        let width = self.collectionViewTile.frame.size.width/2 - 10
        let height = self.isPhone_5_5c_5c_SE() ? self.collectionViewTile.frame.size.height - 20 : self.collectionViewTile.frame.size.height/2 - 10
        let horizontalCV = HorizontalFlowLayout();
        horizontalCV.itemSize = CGSize(width: width, height: height)
        self.collectionViewTile.collectionViewLayout = horizontalCV
    }
    
    func isPhone_5_5c_5c_SE() -> Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    
    func isFindingData(index: Int) -> Bool {
        switch index {
        case 0:
            guard let eventTile = self.dashboardItems.filter({ $0.type == .event }).first, eventTile.onProgress else { return false }
            return true
        case 1:
            guard let tile = self.dashboardItems.filter({ $0.type == .toDo }).first, tile.onProgress else { return false }
            return true
        case 2:
            guard let tile = self.dashboardItems.filter({ $0.type == .shopping }).first, tile.onProgress else { return false }
            return true
        case 3:
            guard let tile = self.dashboardItems.filter({ $0.type == .giftCard }).first, tile.onProgress else { return false }
            return true
        case 4:
            guard let tile = self.dashboardItems.filter({ $0.type == .purchase }).first, tile.onProgress else { return false }
            return true
        default:
            return false
        }
    }
    
    func startLoadingIndicatorForCards(_ type: DashBoardTitle) {
        DispatchQueue.main.async {
            switch type {
            case .event where self.currentSearchEventIndex == 0:
                self.startCardLoading(type)
            case .toDo where self.currentSearchToDoIndex == 0:
                self.startCardLoading(type)
            case .purchase where self.currentSearchPurchaseIndex == 0:
                self.startCardLoading(type)
            case .giftCard where self.currentSearchGiftIndex == 0:
                self.startCardLoading(type)
            case .shopping where self.currentSearchShoppingIndex == 0:
                self.startCardLoading(type)
            default: break
            }
        }
    }
    
    func startCardLoading(_ type: DashBoardTitle) {
        if let index = self.dashboardItems.firstIndex(where: { return $0.type == type }) {
            self.dashboardItems[index].onProgress = true
            let indexPath = IndexPath(item: index, section: 0)
            if index < self.collectionViewTile.numberOfItems(inSection: 0), let cell = self.collectionViewTile.cellForItem(at: indexPath) as? DashboardItemsCollectionViewCell {
                cell.manageDashboardItemProgress(section: self.activeDashBoardSection)
            }
        }
    }
    
    func stopLoadingIndicatorForCards(_ type: DashBoardTitle) {
        DispatchQueue.main.async {
            if let index = self.dashboardItems.firstIndex(where: { return $0.type == type }) {
                self.dashboardItems[index].onProgress = false
                let indexPath = IndexPath(item: index, section: 0)
                if index < self.collectionViewTile.numberOfItems(inSection: 0), let cell = self.collectionViewTile.cellForItem(at: indexPath) as? DashboardItemsCollectionViewCell {
                    cell.manageDashboardItemProgress(section: self.activeDashBoardSection)
                }
            }
        }
    }
    
    func manageAllUserTileTabData() {
        self.manageUserTileAndAnimation(dataType: .event)
        self.manageUserTileAndAnimation(dataType: .toDo)
        self.manageUserTileAndAnimation(dataType: .shopping)
        self.manageUserTileAndAnimation(dataType: .giftCard)
        self.manageUserTileAndAnimation(dataType: .purchase)
    }
    
    func manageUserTileAndAnimation(dataType: DashBoardTitle) {
        self.startLoadingIndicatorForCards(dataType)
        self.updateSpecificTileData(dataType: dataType)
    }
    
    func updateSpecificTileData(dataType: DashBoardTitle) {
        self.manageDashboardSpecificData(using: self.activeDashBoardSection, dataType: dataType) { (response) in
            guard let key = response.keys.first, let datas = response.values.first else { return }
            self.updateTileAndCards(datas, type: key)
        }
    }
    
    func manageDashboardSpecificData(using section: DashBoardSection, dataType: DashBoardTitle, completion: @escaping ([DashBoardTitle: [Any]]) -> ()) {
        let allExcludedSections = self.customDashboard?.readAllExcludedSections().compactMap({ $0.readSectionName() })
        switch dataType {
        case .event:
            var allEvents = self.readEventsOf(section)
            DispatchQueue.main.async {
                if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.event.rawValue }) {
                    completion([DashBoardTitle.event: []])
                }
                else {
                    allEvents = self.filterEventWithDashboardTag(allEvents, on: self.customDashboard)
                    completion([DashBoardTitle.event: allEvents])
                }
            }
        case .toDo:
            var specificTodos = self.readToDos(section)
            DispatchQueue.main.async {
                if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.todo.rawValue }) {
                    completion([DashBoardTitle.toDo: []])
                }
                else {
                    specificTodos = self.filterToDoWithDashboardTag(specificTodos, on: self.customDashboard)
                    completion([DashBoardTitle.toDo: specificTodos])
                }
            }
        case .giftCard:
            var specificGiftCards = self.readGiftCards(section)
            DispatchQueue.main.async {
                if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.gift.rawValue }) {
                    completion([DashBoardTitle.giftCard: []])
                }
                else {
                    specificGiftCards = self.filterGiftWithDashboardTag(specificGiftCards, on: self.customDashboard)
                    completion([DashBoardTitle.giftCard: specificGiftCards])
                }
            }
        case .purchase:
            var purchases = self.readPurchases(section)
            DispatchQueue.main.async {
                if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.purchase.rawValue }) {
                     completion([DashBoardTitle.purchase: []])
                }
                else {
                    purchases = self.filterPurchaseWithDashboardTag(purchases, on: self.customDashboard)
                    completion([DashBoardTitle.purchase: purchases])
                }
            }
            break;
        case .shopping:
            var shopping = self.readShopping(section)
            DispatchQueue.main.async {
                if let sections = allExcludedSections, sections.contains(where: { $0 == DashboardSectionType.shopping.rawValue }) {
                     completion([DashBoardTitle.shopping: []])
                }
                else {
                    shopping = self.filterShopListItemWithDashboardTag(shopping, on: self.customDashboard)
                    completion([DashBoardTitle.shopping: shopping])
                }
            }
        }
    }
    
    func updateTileAndCards(_ datas: [Any], type: DashBoardTitle) {
        let reorderData = self.reorderCardData(datas)
        self.updateCardData(reorderData, dashBoardSection: self.activeDashBoardSection, dataType: type)
    }
    
    func calculateOverDueToDo() {
        let databasePlanItTodo = DataBasePlanItTodo()
        let startDate = Date().initialHour()
        databasePlanItTodo.readAllAvailableTodosUsingQueue(result: { allTodos in
            let overdueTodos = allTodos.filter({ return !$0.completed || $0.readDeleteStatus() }).filter({ if !$0.isRecurrenceTodo() { if let dueDate = $0.readExactDueDate(), dueDate < startDate { return !$0.completed && !$0.readDeleteStatus() } else { return false } } else { if let dueDate = $0.readStartDate(using: .overdue), dueDate < startDate { return !$0.completed && !$0.readDeleteStatus() } else { return false } } })
            DispatchQueue.main.async {
                let convertedTodos = overdueTodos.compactMap({ return try? databasePlanItTodo.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
                self.overDueToDo = convertedTodos
                self.viewDashBoardCardList.updateCardToDoOverDueData(on: convertedTodos, type: .toDo, section: self.activeDashBoardSection)
            }
        })
    }
    
    func updateCardData(_ data: [Any], dashBoardSection: DashBoardSection = .today, dataType: DashBoardTitle) {
        switch dataType {
        case .event:
            self.dashboardItems[0].items = data
            if self.isReachedMaximumEventLimit() || dashBoardSection != .all {
                Session.shared.saveEachTypesSectionCount(dashBoardSection, count: data.count, type: dataType)
            }
            self.collectionViewTile.reloadItems(at: [IndexPath(row: 0, section: 0)])
            self.viewDashBoardCardList.updateCardData(on: data, type: .event, section: dashBoardSection)
        case .toDo:
            self.dashboardItems[1].items = data
            if self.isReachedMaximumTodoLimit() || dashBoardSection != .all {
                Session.shared.saveEachTypesSectionCount(dashBoardSection, count: data.count, type: dataType)
            }
            self.collectionViewTile.reloadItems(at: [IndexPath(row: 1, section: 0)])
            self.viewDashBoardCardList.updateCardData(on: data, type: .toDo, section: dashBoardSection)
        case .shopping:
            self.dashboardItems[2].items = data
            if self.isReachedMaximumShoppingLimit() || dashBoardSection != .all {
                Session.shared.saveEachTypesSectionCount(dashBoardSection, count: data.count, type: dataType)
            }
            self.collectionViewTile.reloadItems(at: [IndexPath(row: 2, section: 0)])
            self.viewDashBoardCardList.updateCardData(on: data, type: .shopping, section: dashBoardSection)
        case .giftCard:
            self.dashboardItems[3].items = data
            if self.isReachedMaximumGiftLimit() || dashBoardSection != .all {
                Session.shared.saveEachTypesSectionCount(dashBoardSection, count: data.count, type: dataType)
            }
            self.collectionViewTile.reloadItems(at: [IndexPath(row: 3, section: 0)])
            self.viewDashBoardCardList.updateCardData(on: data, type: .giftCard, section: dashBoardSection)
        case .purchase:
            self.dashboardItems[4].items = data
            if self.isReachedMaximumPurchaseLimit() || dashBoardSection != .all {
                Session.shared.saveEachTypesSectionCount(dashBoardSection, count: data.count, type: dataType)
            }
            self.collectionViewTile.reloadItems(at: [IndexPath(row: 4, section: 0)])
            self.viewDashBoardCardList.updateCardData(on: data, type: .purchase, section: dashBoardSection)
        }
    }
    
    fileprivate func reorderCardData(_ data: [Any]) -> [Any] {
        if let events = data as? [DashboardEventItem] {
            return self.reorderEvent(event: events)
        }
        else if let toDoItem = data as? [DashboardToDoItem] {
            return self.reorderToDo(toDo: toDoItem)
        }
        else if let planItPurchase = data as? [DashboardPurchaseItem] {
            return self.reorderPurchase(purchase: planItPurchase)
        }
        else if let gift = data as? [DashboardGiftItem] {
            return self.reorderGift(gift: gift)
        }
        else if let shopListItem = data as? [DashboardShopListItem] {
            return self.reorderShopListItem(shopListItem: shopListItem)
        }
        return []
    }
    
    fileprivate func reorderEvent(event: [DashboardEventItem]) -> [DashboardEventItem] {
        return event.sorted(by: { return ($0.isAllDay ? $0.initialDate : $0.start) < ($1.isAllDay ? $1.initialDate : $1.start) })
    }
    
    fileprivate func reorderToDo(toDo: [DashboardToDoItem]) -> [DashboardToDoItem] {
        let unPlannedTodos = toDo.filter({ return $0.actualDate == nil }).sorted(by: { return $0.text < $1.text })
        let plannedTodos = toDo.filter({ return $0.actualDate != nil }).sorted(by: { if let date1 = $0.actualDate, let date2 = $1.actualDate { return date1 < date2 } else { return false } })
        return unPlannedTodos + plannedTodos
    }
    
    fileprivate func reorderPurchase(purchase: [DashboardPurchaseItem]) -> [DashboardPurchaseItem] {
        return purchase.sorted(by: { return $0.bilDateTime < $1.bilDateTime })
    }
    
    fileprivate func reorderShopListItem(shopListItem: [DashboardShopListItem]) -> [DashboardShopListItem] {
        let unPlannedShopping = shopListItem.filter({ return $0.actualDueDate == nil }).sorted(by: { return $0.itemName < $1.itemName })
        let plannedShopping = shopListItem.filter({ return $0.actualDueDate != nil }).sorted(by: { if let date1 = $0.actualDueDate, let date2 = $1.actualDueDate { return date1 < date2 } else { return false } })
        return unPlannedShopping + plannedShopping
    }
    
    fileprivate func reorderGift(gift: [DashboardGiftItem]) -> [DashboardGiftItem] {
        let unPlannedGift = gift.filter({ return $0.exipryDate == nil }).sorted(by: { return $0.title < $1.title })
        let plannedGift = gift.filter({ return $0.exipryDate != nil }).sorted(by: { if let date1 = $0.exipryDate, let date2 = $1.exipryDate { return date1 < date2 } else { return false } })
        return unPlannedGift + plannedGift
    }
}


extension DashBoardViewController {
    
    func isCustomDashBord() -> Bool {
        return self.customDashboard != nil
    }
}
