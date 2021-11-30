//
//  CheckUserNameResponse.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct CheckUserNameResponse: Codable {
    let message: String
    let processTime, status: Int

    enum CodingKeys: String, CodingKey {
        case message
        case processTime = "process_time"
        case status
    }
}
