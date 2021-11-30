//
//  DeleteGroupService.swift
//  Many-to-many-call
//
//  Created by usama farooq on 30/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
struct DeleteResponse: Codable {
    let message: String
    let processTime, status: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case processTime = "process_time"
        case status
    }
}

typealias DeleteComplitionHandler = (Result<DeleteResponse, Error>) -> Void

protocol DeleteStoreable {
    func delete(with request: DeleteGroupRequest, complitionHandler: @escaping DeleteComplitionHandler)
}

class DeleteService: BaseDataStore, DeleteStoreable {
    
    let translation: ObjectTranslator
    init(service: Service, translation: ObjectTranslator = ObjectTranslation()) {
        self.translation = translation
        super.init(service: service)
    }
    
    func delete(with request: DeleteGroupRequest, complitionHandler: @escaping DeleteComplitionHandler) {
        service.post(request: request) { response in
            switch response {
            case .failure(let error):
                print(error)
            case .success(let data):
                self.translate(data: data, complition: complitionHandler)
                
            }
        }
    }
    
    private func translate(data: Data, complition: DeleteComplitionHandler) {
        do {
            let response: DeleteResponse = try translation.decodeObject(data: data)
            complition(.success(response))
        } catch let error{
            complition(.failure(error))

        }

    }
    
    
}
