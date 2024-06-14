//
//  PINRemoteUIImageView.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 06/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit
import PINRemoteImage

extension UIImageView {
    
    func pinImageFromURL(_ url: URL?, placeholderImage: UIImage?, completion: ((PINRemoteImageManagerResult) -> ())? = nil) {
        if let filePath = url?.path, SocialManager.default.isNetworkReachable(), self.includedInRefreshCache(filePath), !Session.shared.readCache().contains(filePath) {
            url?.removeCachedContents()
            Session.shared.saveToCache(filePath)
            self.pin_setImage(from: url, placeholderImage: placeholderImage, completion: completion)
        }
        else {
            if SocialManager.default.isNetworkReachable() {
                self.pin_setImage(from: url, placeholderImage: placeholderImage, completion: completion)
            }
            else {
                self.pin_setImage(from: url, placeholderImage: placeholderImage)
                completion?(PINRemoteImageManagerResult.init())
            }
        }
    }
    
    func includedInRefreshCache(_ path: String) -> Bool {
        return path.range(of: "/purchase/", options: .caseInsensitive) == nil && path.range(of: "/gift/", options: .caseInsensitive) == nil && path.range(of: "/shopping/", options: .caseInsensitive) == nil && path.range(of: "/task/", options: .caseInsensitive) == nil
    }
}
