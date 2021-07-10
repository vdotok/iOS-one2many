//
//  AllUserRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation

struct AllUserRequest: APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "AllUsers"
    }
    func getBody() -> Data? {
        return nil
    }
    
    
}
