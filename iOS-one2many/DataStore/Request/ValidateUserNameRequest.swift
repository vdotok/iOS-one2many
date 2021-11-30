//
//  ValidateUserNameRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct ValidateUserNameRequest: Codable, APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
       return "CheckEmail"
    }
    
    func getBody() -> Data? {
        do {
           return try JSONEncoder().encode(self)
        } catch {
            return Data()
        }
    }
    
    let email: String
    
}
