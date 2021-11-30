//
//  CreateGroupRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct CreateGroupRequest: APIRequest {
    
    func getMethod() -> RequestType {
        .POST
    }
    func getPath() -> String {
        "CreateGroup"
    }
    let groupTitle: String
    let participants: [Int]
    var autoCreated: Int? = 0
    enum CodingKeys: String, CodingKey {
        case groupTitle = "group_title"
        case participants
        case autoCreated = "auto_created"
    }
}
