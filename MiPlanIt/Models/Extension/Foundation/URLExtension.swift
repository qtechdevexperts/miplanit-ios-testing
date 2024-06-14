//
//  URLExtension.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 06/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension URL {
    
    func removeCachedContents() {
        let orginal = PINRemoteImageManager.shared().cacheKey(for: self, processorKey: nil)
        PINRemoteImageManager.shared().cache.removeObject(forKey: orginal)
        let rounded = PINRemoteImageManager.shared().cacheKey(for: self, processorKey: "rounded")
        PINRemoteImageManager.shared().cache.removeObject(forKey: rounded)
    }
    
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
