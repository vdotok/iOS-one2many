//
//  CreateGroupService.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation

typealias GroupComplition = ((Result<CreateGroupResponse, Error>) -> Void)


protocol GroupStorable {
    func createGroup(with request: CreateGroupRequest, complition: @escaping GroupComplition)
}

class CreateGroupService: BaseDataStore, GroupStorable {
    
    let translator: ObjectTranslator
    
    init(service: Service, translator: ObjectTranslator = ObjectTranslation()) {
        self.translator = translator
        super.init(service: service)
    }
    
    func createGroup(with request: CreateGroupRequest, complition: @escaping GroupComplition) {
        service.post(request: request) { (result) in
            switch result {
            case .success(let data):
                self.translate(data: data, complition: complition)
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    private func translate(data: Data, complition: GroupComplition) {
        do {
            let response: CreateGroupResponse = try translator.decodeObject(data: data)
            complition(.success(response))
        }
        catch {
            complition(.failure(error))
        }
    }
    
}
