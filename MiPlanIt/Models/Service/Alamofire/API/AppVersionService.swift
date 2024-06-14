//
//  AppVersionService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 25/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class AppVersionService {
    
    func getAppVersion(callback: @escaping (Bool?, String?) -> ()) {
        let appVersionCommand = AppVersionCommand()
        appVersionCommand.getAppVersion { (response, error) in
            if let data = response {
                if let appVersion = data["app_version"] as? String {
                    Storage().saveString(object: appVersion, forkey: UserDefault.appVersion)
                }
                Storage().saveBool(flag: data["app_version_force_upd"] as? Bool  ?? false, forkey: UserDefault.forceUpdate)
                Storage().saveString(object: data["app_version_details"] as? String  ?? Strings.empty, forkey: UserDefault.appVersionMessage)
                callback(true, nil)
            }
            else {
                callback(nil, error)
            }
        }
    }
    
}


class AppVersionCommand: WSManager {

    func getAppVersion(callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.appVersion, callback: { response, error in
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
}
