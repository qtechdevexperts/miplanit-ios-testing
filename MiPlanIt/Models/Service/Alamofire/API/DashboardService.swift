//
//  DashboardService.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
class DashboardService {
    
    func fetchCustomDashboardData(_ user: PlanItUser, callback: @escaping (Bool, String?) -> ()) {
        let requestParameter:[String: Any] = ["userId": Session.shared.readUserId() , "lastSyncDate": user.readUserSettings().readLastFetchUserDashboardDataTime() ]
        let serviceCommand = DashboardCommand()
        serviceCommand.fetchCustomDashboards(requestParameter) { (response, error) in
            if let result = response{
                DatabasePlanItDashboard().insertOrUpdateDashboard(result) {
                    if let lastSyncTime = result["lastSyncDate"] as? String {
                        user.readUserSettings().saveLastFetchUserDashboardDataTime(lastSyncTime)
                    }
                    callback(true, error)
                }
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func updateDashboardPic(_ dashboard: Dashboard, file: String, name: String, callback: @escaping (Bool, String?) -> ()) {
        let serviceCommand = DashboardCommand()
        guard let dashboarId = dashboard.planItDashBoard?.readValueOfDashboarId(), let dashboardOwner = dashboard.planItDashBoard?.readOwnerUserId() else { callback(false, nil); return }
        serviceCommand.uploadProfilePic(["userDashboardId": dashboarId, "fileName": name, "fileData": file, "userId": dashboardOwner], callback: { response, error in
            if let result = response, let image = result["userDashboardImage"] as? String {
                dashboard.saveDashboardImage(image)
                callback(true, nil)
            }
            else {
                callback(false, error)
            }
        })
    }
    
    func addDashboard(_ dashboard: Dashboard, callback: @escaping (PlanItDashboard?, String?) -> ()) {
        var requestParameter:[String: Any] = dashboard.createRequestParameter()
        requestParameter["userId"] = Session.shared.readUserId()
        let dashboardCommand = DashboardCommand()
        dashboardCommand.createDashboard(requestParameter) { (response, error) in
            if let result = response, let allDashboard = result["userDashboard"] as? [[String: Any]], let userDashboard = allDashboard.first {
                let plantDashboard = DatabasePlanItDashboard().insertOrUpdateDashboard(userDashboard)
                callback(plantDashboard, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func deletedashboard(_ dashboard: PlanItDashboard, callback: @escaping (Bool, String?) -> ()) {
        let dashboardCommand = DashboardCommand()
        dashboardCommand.deleteDashboard(["userId": Session.shared.readUserId(),"userDashboardId": [dashboard.readValueOfDashboarId()]]) { (response, error) in
            if let _ = response {
                dashboard.deleteItSelf()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
}

class DashboardCommand: WSManager {
    
    func fetchCustomDashboards(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.customDashboardFetch, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func uploadProfilePic(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.uploadDashboardPic, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    func createDashboard(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.dashboardAdd, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func deleteDashboard(_ params: [String: Any]?, callback: @escaping (String?, String?) -> ()) {
        self.delete(endPoint: ServiceData.dashboardDelete, params: params) { (response, error) in
            if let result = response {
                if let data = result.statusCode, data == "SU001" {
                    callback(result.error, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
}
