//
//  AllGroupRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation

struct AllGroupRequest: Codable, APIRequest {
    
    func getMethod() -> RequestType {
        .GET
    }
    
    func getPath() -> String {
        "AllGroups"
    }
    
    func getBody() -> Data? {
        return nil
    }
    
}
