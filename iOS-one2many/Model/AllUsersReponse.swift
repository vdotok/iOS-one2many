//
//  AllUsersReponse.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct AllUsersResponse: Codable {
    let message: String
    let processTime, status: Int
    let users: [User]

    enum CodingKeys: String, CodingKey {
        case message
        case processTime = "process_time"
        case status, users
    }
}

// MARK: - User
struct User: Codable {
    let email, fullName, refID: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case refID = "ref_id"
        case userID = "user_id"
    }
}
