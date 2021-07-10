//
//  EditGroupService.swift
//  Many-to-many-call
//
//  Created by usama farooq on 30/06/2021.
//

import Foundation
struct EditResponse: Codable {
    let message: String
     let processTime, status: Int

     enum CodingKeys: String, CodingKey {
         case message
         case processTime = "process_time"
         case status
     }
}

typealias EditGroupComplitionHandler = (Result<EditResponse, Error>) -> Void

protocol EditGroupStoreable {
    func editGroup(with request: EditGroupRequest, complitionHandler: @escaping EditGroupComplitionHandler)
}


class EditGroupService: BaseDataStore,EditGroupStoreable {

    let translation: ObjectTranslator
    init(service: Service, translation: ObjectTranslator = ObjectTranslation()) {
        self.translation = translation
        super.init(service: service)
    }
    
    func editGroup(with request: EditGroupRequest, complitionHandler: @escaping EditGroupComplitionHandler) {
        service.post(request: request) { [weak self] result in
            switch result {
            case .failure(let error):
                complitionHandler(.failure(error))
            case .success(let data):
                self?.translate(data: data, complition: complitionHandler)
            }
        }
    }
    
    private func translate(data: Data, complition: EditGroupComplitionHandler) {
        do {
            let response: EditResponse = try translation.decodeObject(data: data)
            complition(.success(response))
        } catch let error{
            complition(.failure(error))
            
        }
        
    }
    
}
