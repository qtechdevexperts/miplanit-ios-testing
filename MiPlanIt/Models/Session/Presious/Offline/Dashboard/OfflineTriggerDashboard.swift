//
//  OfflineTriggerDashboard.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {

    func sendDashboardToServer(_ finished: @escaping () -> ()) {
        let pendingDashboard = DatabasePlanItDashboard().readAllPendingDashboards()
        if pendingDashboard.isEmpty {
            self.sendDeleteDashboardToServer(finished)
        }
        else {
            self.startDashboardSending(pendingDashboard) {
                self.sendDeleteDashboardToServer(finished)
            }
        }
    }
    
    private func startDashboardSending(_ dashboard: [PlanItDashboard], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < dashboard.count {
            self.sendDashboardToServer(calendar: dashboard[atIdex], at: atIdex, result: { index in
                self.startDashboardSending(dashboard, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDashboardToServer(calendar: PlanItDashboard, at index: Int, result: @escaping (Int) -> ()) {
        let newDashboard = Dashboard(with: calendar)
        DashboardService().addDashboard(newDashboard) { (response, error) in
            if let _ = response {
                self.sendDashboardImageToServer(dashbord: newDashboard, at: index, result: result)
            }
            else {
                result(index)
            }
        }
    }
    
    private func sendDashboardImageToServer(dashbord: Dashboard, at index: Int, result: @escaping (Int) -> ()) {
        if let _ = Session.shared.readUser(), let planItDashboard = dashbord.planItDashBoard, let data = planItDashboard.dashboardImageData, !data.isEmpty {
            let fileName = String(Date().millisecondsSince1970) + Extensions.png
            DashboardService().updateDashboardPic(dashbord, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName) { (_, _) in
                result(index)
            }
        }
        else {
            result(index)
        }
    }
    
    func sendDeleteDashboardToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedDashboard = DatabasePlanItDashboard().readAllPendingDeletedDashboards()
        if pendingDeletedDashboard.isEmpty {
            finished()
        }
        else {
            self.startDeletedDashboardSending(pendingDeletedDashboard) {
                finished()
            }
        }
    }
    
    private func startDeletedDashboardSending(_ dashboard: [PlanItDashboard], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < dashboard.count {
            self.sendDeletedDashboardToServer(sendDeletedDashboardToServer: dashboard[atIdex], at: atIdex, result: { index in
                self.startDeletedDashboardSending(dashboard, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedDashboardToServer(sendDeletedDashboardToServer: PlanItDashboard, at index: Int, result: @escaping (Int) -> ()) {
        DashboardService().deletedashboard(sendDeletedDashboardToServer) { (status, error) in
            result(index)
        }
    }

}
