//
//  AllGroupService.swift
//  Many-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//

import Foundation
typealias GroupsComplition = ((Result<GroupResponse, Error>) -> Void)


protocol AllGroupStroreable {
    func fetchGroups(with request: AllGroupRequest, complition: @escaping GroupsComplition)
}

class AllGroupService: BaseDataStore, AllGroupStroreable {

    let translator: ObjectTranslator
    
    init(service: Service, translator: ObjectTranslator = ObjectTranslation()) {
        self.translator = translator
        super.init(service: service)
    }
    
    func fetchGroups(with request: AllGroupRequest, complition: @escaping GroupsComplition) {
        service.get(request: request) { [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                self.translate(data: data, complition: complition)
            case .failure(let error):
                complition(.failure(error))
                
            }
        }
    }
    
    private func translate(data: Data, complition: GroupsComplition) {
        do {
            let response: GroupResponse = try translator.decodeObject(data: data)
            complition(.success(response))
        }
        catch {
            complition(.failure(error))
        }
    }
}
