//
//  ViewContainer.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MobileCoreServices

enum ViewContainerError: Error {
    case invalidType, unarchiveFailure
}

class ViewContainer: NSObject {
    
    let view: InviteesDragView!
    
    required init(view: InviteesDragView) {
        self.view = view
    }
}

extension ViewContainer: NSItemProviderReading {
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeImage as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        if typeIdentifier == kUTTypeImage as String {
            guard let view = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InviteesDragView else { throw ViewContainerError.unarchiveFailure }
            return self.init(view: view)
        }
        else {
            throw ViewContainerError.invalidType
        }
    }
}

extension ViewContainer: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeImage as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == kUTTypeImage as String {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: view!, requiringSecureCoding: false)
                completionHandler(data, nil)
            } catch {
                completionHandler(nil, error)
            }
        } else {
            completionHandler(nil, ViewContainerError.invalidType)
        }
        return nil
    }
   
}
