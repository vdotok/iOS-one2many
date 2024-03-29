//
//  ApiRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

public enum RequestType: String, Codable {
    case GET, POST, PUT, DELETE
    
}

protocol APIRequest: Encodable {
    func getMethod() ->     RequestType
    func getPath() ->       String
    func getBody() ->       Data?
    func getBoundary() ->   String
    func getToken() ->      (key: String, value: String)?
}

extension APIRequest {
    
    func request() -> URLRequest {
        let url = getBaseUrl()
        var request = URLRequest(url: url)
        request.httpMethod = getMethod().rawValue
        if getMethod() == .GET {
            request.httpBody = nil
        }else {
            request.httpBody = getBody()
        }
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        if let externalHeader = getToken() {
            request.addValue(externalHeader.value, forHTTPHeaderField: externalHeader.key)
        }
        
        return request
    }
    
    func getBody() -> Data? { try? JSONEncoder().encode(self) }
    
    func getBoundary() -> String {
        return ""
    }
    
    func getToken() -> (key: String, value: String)? {
        guard let token = VDOTOKObject<String>().getToken() else {
            return nil
        }
        return ("Authorization", "Bearer \(token)")
    }
    
    private func getBaseUrl() -> URL {
        let fakeUrl = URL(fileURLWithPath: "")
        guard let baseUrl = URL(string:AuthenticationConstants.TENANTSERVER),
              let component = URLComponents(url: baseUrl.appendingPathComponent(getPath()), resolvingAgainstBaseURL: false), let url = component.url else {
            print("Unable to create URL components")
            return fakeUrl
        }
        return url
    }
    
}

struct Configurations {
    static let apiVersion = "API/v0"
    static let scheme = "https"
}
