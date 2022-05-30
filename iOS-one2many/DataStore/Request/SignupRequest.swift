//
//  SignupRequest.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

struct SignupRequest: Codable, APIRequest {
    
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        return "SignUp"
    }
    
    let fullName: String
    let email, password: String
    let projectID: String = AuthenticationConstants.PROJECTID
    let deviceType: String = UIDevice.current.systemName
    let deviceModel: String = UIDevice.current.model
    let deviceOSVer: String = UIDevice.current.systemVersion
    let appVersion: String = Bundle.main.buildVersionNumber ?? "0"
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email, password
        case projectID = "project_id"
        case deviceType = "device_type"
        case deviceModel = "device_model"
        case deviceOSVer = "device_os_ver"
        case appVersion = "app_version"
    }
    
    
}
