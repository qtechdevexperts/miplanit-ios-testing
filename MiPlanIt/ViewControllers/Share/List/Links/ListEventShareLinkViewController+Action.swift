//
//  ListEventShareLinkViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ListEventShareLinkViewController{
    
    func initializeData() {
        self.constraintSearchViewHeight.constant = 0
        self.readAllUserShareLinkList()
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.createServiceToUsersShareList()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        if !self.apiCallInProgress {
            self.createServiceToUsersShareList(onPullToRefresh: true)
        }
    }
    
    func updateSearchHeight(sender: UIButton) {
        self.constraintSearchViewHeight.constant = self.constraintSearchViewHeight.constant == 45 ? 0 : 45
        if self.constraintSearchViewHeight.constant == 0 {
            self.textFieldSearch.resignFirstResponder()
            self.clearSearch()
        }
        else {
            _ = self.textFieldSearch.becomeFirstResponder()
        }
    }
    
    func clearSearch() {
        self.textFieldSearch.text = Strings.empty
        self.buttonSearch.isSelected = false
        self.buttonClearSearch.isHidden = true
        if self.filterCriteria == nil {
            self.searchListUsingText(text: Strings.empty, baseArray: self.allShareLinks)
        }
        else {
            self.showListBasedOnFilterCriteria()
        }
    }
    
    func stopPullToRefresh() {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    func readAllUserShareLinkList()  {
        self.allShareLinks = DatabasePlanItShareLink().readAllUserShareLink()
    }
    
    func showErrorMessage(_ message: String) {
        if self.allShareLinks.isEmpty {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
        }
    }
    
    func removeSharedLinkList(_ deletedShareLink: PlanItShareLink) {
        self.allShareLinks.removeAll { (shareLink) -> Bool in
            if shareLink.readEventShareLinkId() != 0.0 {
                return shareLink.readEventShareLinkId() == deletedShareLink.readEventShareLinkId()
            }
            else {
                return shareLink.readEventAppShareLinkId() == deletedShareLink.readEventAppShareLinkId()
            }
        }
    }
    
    func showListBasedOnFilterCriteria(searchText: String = Strings.empty) {
        self.buttonFilterOption.isSelected = self.filterCriteria != nil
        guard let dropDownOptionType = self.filterCriteria else {
            self.searchListUsingText(text: self.getSearchText(), baseArray: self.allShareLinks)
            return
        }
        var filteresData = self.allShareLinks
        if dropDownOptionType == .eActive {
            filteresData = filteresData.filter({ !($0.isEpired() ?? true) })
        }
        else {
            filteresData = filteresData.filter({ ($0.isEpired() ?? true) })
        }
        let text = !searchText.isEmpty ? searchText : textFieldSearch.text ?? Strings.empty
        if !text.isEmpty {
            self.searchListUsingText(text: text, baseArray: filteresData)
        }
        else {
            self.showShareListLists = filteresData
        }
    }
    
    func getSearchText() -> String {
        return (self.textFieldSearch.text ?? Strings.empty).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func searchListUsingText(text: String, baseArray: [PlanItShareLink]) {
        self.buttonSearch.isSelected = !text.isEmpty
        self.buttonClearSearch.isHidden = text.isEmpty
        guard !text.isEmpty else { self.showShareListLists = baseArray; return }
        self.showShareListLists = baseArray.filter({ return $0.readEventName().range(of: text, options: .caseInsensitive) != nil })
    }
    
    func showWarningAlertForShareLink(_ shareLink: PlanItShareLink, onIndex indexPath: IndexPath) {
        self.showAlertWithAction(message: shareLink.readWarning(), title: Message.warning, items: [Message.editShareLink, Message.cancel], callback: { index in
            if index == 0 {
                self.showShareLinkDetail(on: indexPath)
            }
        })
    }
    
    func showShareLinkDetail(on index: IndexPath) {
        if let expired = self.showShareListLists[index.row].isEpired(), expired {
            return
        }
        self.performSegue(withIdentifier: Segues.showShareLink, sender: self.showShareListLists[index.row])
    }
}
