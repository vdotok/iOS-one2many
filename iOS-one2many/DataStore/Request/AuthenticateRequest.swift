//
//  AuthenticateRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//

import Foundation
struct AuthenticateRequest: Codable, APIRequest {
    
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
       return "AuthenticateSDK"
    }
    
    func getBoundry() -> String {
       return ""
    }
    
    func getBody() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return Data()
        }
    }
    
   let auth_token: String
   let project_id: String
    
    
}
