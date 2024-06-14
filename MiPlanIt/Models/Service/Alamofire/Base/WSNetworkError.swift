//
//  WSNetworkError.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class WSNetworkError {
    
    var code: Int = 0
    var message: String = "An unknown error occured"
    
    init(error: Any, code: Int? = nil) {
        if let err = error as? NSError {
            self.message = err.localizedDescription
            self.code = err.code
        } else {
            if let desc = error as? String {
                self.message = desc
            }
            if let errorCode = code  {
                self.code = errorCode
            }
        }
    }
}
