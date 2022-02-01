//
//  CreateGroupResponse.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
struct CreateGroupResponse: Codable {
    let group: Group?
    let message: String
    let processTime, status: Int
    let isalreadyCreated: Bool?

    enum CodingKeys: String, CodingKey {
        case group, message
        case processTime = "process_time"
        case status
        case isalreadyCreated = "is_already_created"
        
    }
}
