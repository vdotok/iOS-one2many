//
//  DeleteGroupRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 30/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct DeleteGroupRequest: APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "DeleteGroup"
    }
    
    let group_id: Int
}
