//
//  BaseDataStore.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
class BaseDataStore {
    let service: Service
    
    init(service: Service) {
        self.service = service
    }
}
