//
//  Bundle+Extension.swift
//  iOS-one2many
//
//  Created by usama farooq on 27/05/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import Foundation
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
