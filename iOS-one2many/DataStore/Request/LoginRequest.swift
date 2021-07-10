//
//  LoginRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation

struct LoginRequest: Codable, APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "Login"
    }
    
    func getBody() -> Data? {
        do {
           return try JSONEncoder().encode(self)
        }
        catch {
            return Data()
        }
    }
    
    let email: String
    let password: String
    
}
