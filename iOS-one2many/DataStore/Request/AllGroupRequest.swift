//
//  AllGroupRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
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
